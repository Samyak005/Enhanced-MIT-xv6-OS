
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char* argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 e4 f0             	and    $0xfffffff0,%esp
    psinfo();
   a:	e8 1c 03 00 00       	call   32b <psinfo>
   f:	31 c0                	xor    %eax,%eax
  11:	c9                   	leave  
  12:	c3                   	ret    
  13:	66 90                	xchg   %ax,%ax
  15:	66 90                	xchg   %ax,%ax
  17:	66 90                	xchg   %ax,%ax
  19:	66 90                	xchg   %ax,%ax
  1b:	66 90                	xchg   %ax,%ax
  1d:	66 90                	xchg   %ax,%ax
  1f:	90                   	nop

00000020 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  20:	f3 0f 1e fb          	endbr32 
  24:	55                   	push   %ebp
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  25:	31 c0                	xor    %eax,%eax
{
  27:	89 e5                	mov    %esp,%ebp
  29:	53                   	push   %ebx
  2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while((*s++ = *t++) != 0)
  30:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  34:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  37:	83 c0 01             	add    $0x1,%eax
  3a:	84 d2                	test   %dl,%dl
  3c:	75 f2                	jne    30 <strcpy+0x10>
    ;
  return os;
}
  3e:	89 c8                	mov    %ecx,%eax
  40:	5b                   	pop    %ebx
  41:	5d                   	pop    %ebp
  42:	c3                   	ret    
  43:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000050 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  50:	f3 0f 1e fb          	endbr32 
  54:	55                   	push   %ebp
  55:	89 e5                	mov    %esp,%ebp
  57:	53                   	push   %ebx
  58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  5e:	0f b6 01             	movzbl (%ecx),%eax
  61:	0f b6 1a             	movzbl (%edx),%ebx
  64:	84 c0                	test   %al,%al
  66:	75 19                	jne    81 <strcmp+0x31>
  68:	eb 26                	jmp    90 <strcmp+0x40>
  6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  70:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
    p++, q++;
  74:	83 c1 01             	add    $0x1,%ecx
  77:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  7a:	0f b6 1a             	movzbl (%edx),%ebx
  7d:	84 c0                	test   %al,%al
  7f:	74 0f                	je     90 <strcmp+0x40>
  81:	38 d8                	cmp    %bl,%al
  83:	74 eb                	je     70 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
  85:	29 d8                	sub    %ebx,%eax
}
  87:	5b                   	pop    %ebx
  88:	5d                   	pop    %ebp
  89:	c3                   	ret    
  8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  90:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
  92:	29 d8                	sub    %ebx,%eax
}
  94:	5b                   	pop    %ebx
  95:	5d                   	pop    %ebp
  96:	c3                   	ret    
  97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  9e:	66 90                	xchg   %ax,%ax

000000a0 <strlen>:

uint
strlen(const char *s)
{
  a0:	f3 0f 1e fb          	endbr32 
  a4:	55                   	push   %ebp
  a5:	89 e5                	mov    %esp,%ebp
  a7:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  aa:	80 3a 00             	cmpb   $0x0,(%edx)
  ad:	74 21                	je     d0 <strlen+0x30>
  af:	31 c0                	xor    %eax,%eax
  b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  b8:	83 c0 01             	add    $0x1,%eax
  bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  bf:	89 c1                	mov    %eax,%ecx
  c1:	75 f5                	jne    b8 <strlen+0x18>
    ;
  return n;
}
  c3:	89 c8                	mov    %ecx,%eax
  c5:	5d                   	pop    %ebp
  c6:	c3                   	ret    
  c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  ce:	66 90                	xchg   %ax,%ax
  for(n = 0; s[n]; n++)
  d0:	31 c9                	xor    %ecx,%ecx
}
  d2:	5d                   	pop    %ebp
  d3:	89 c8                	mov    %ecx,%eax
  d5:	c3                   	ret    
  d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  dd:	8d 76 00             	lea    0x0(%esi),%esi

000000e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e0:	f3 0f 1e fb          	endbr32 
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	57                   	push   %edi
  e8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  f1:	89 d7                	mov    %edx,%edi
  f3:	fc                   	cld    
  f4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  f6:	89 d0                	mov    %edx,%eax
  f8:	5f                   	pop    %edi
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    
  fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ff:	90                   	nop

00000100 <strchr>:

char*
strchr(const char *s, char c)
{
 100:	f3 0f 1e fb          	endbr32 
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	8b 45 08             	mov    0x8(%ebp),%eax
 10a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 10e:	0f b6 10             	movzbl (%eax),%edx
 111:	84 d2                	test   %dl,%dl
 113:	75 16                	jne    12b <strchr+0x2b>
 115:	eb 21                	jmp    138 <strchr+0x38>
 117:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 11e:	66 90                	xchg   %ax,%ax
 120:	0f b6 50 01          	movzbl 0x1(%eax),%edx
 124:	83 c0 01             	add    $0x1,%eax
 127:	84 d2                	test   %dl,%dl
 129:	74 0d                	je     138 <strchr+0x38>
    if(*s == c)
 12b:	38 d1                	cmp    %dl,%cl
 12d:	75 f1                	jne    120 <strchr+0x20>
      return (char*)s;
  return 0;
}
 12f:	5d                   	pop    %ebp
 130:	c3                   	ret    
 131:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return 0;
 138:	31 c0                	xor    %eax,%eax
}
 13a:	5d                   	pop    %ebp
 13b:	c3                   	ret    
 13c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	f3 0f 1e fb          	endbr32 
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
 147:	57                   	push   %edi
 148:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 149:	31 f6                	xor    %esi,%esi
{
 14b:	53                   	push   %ebx
 14c:	89 f3                	mov    %esi,%ebx
 14e:	83 ec 1c             	sub    $0x1c,%esp
 151:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 154:	eb 33                	jmp    189 <gets+0x49>
 156:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 15d:	8d 76 00             	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 160:	83 ec 04             	sub    $0x4,%esp
 163:	8d 45 e7             	lea    -0x19(%ebp),%eax
 166:	6a 01                	push   $0x1
 168:	50                   	push   %eax
 169:	6a 00                	push   $0x0
 16b:	e8 2b 01 00 00       	call   29b <read>
    if(cc < 1)
 170:	83 c4 10             	add    $0x10,%esp
 173:	85 c0                	test   %eax,%eax
 175:	7e 1c                	jle    193 <gets+0x53>
      break;
    buf[i++] = c;
 177:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 17b:	83 c7 01             	add    $0x1,%edi
 17e:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 181:	3c 0a                	cmp    $0xa,%al
 183:	74 23                	je     1a8 <gets+0x68>
 185:	3c 0d                	cmp    $0xd,%al
 187:	74 1f                	je     1a8 <gets+0x68>
  for(i=0; i+1 < max; ){
 189:	83 c3 01             	add    $0x1,%ebx
 18c:	89 fe                	mov    %edi,%esi
 18e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 191:	7c cd                	jl     160 <gets+0x20>
 193:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 195:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 198:	c6 03 00             	movb   $0x0,(%ebx)
}
 19b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 19e:	5b                   	pop    %ebx
 19f:	5e                   	pop    %esi
 1a0:	5f                   	pop    %edi
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    
 1a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1a7:	90                   	nop
 1a8:	8b 75 08             	mov    0x8(%ebp),%esi
 1ab:	8b 45 08             	mov    0x8(%ebp),%eax
 1ae:	01 de                	add    %ebx,%esi
 1b0:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 1b2:	c6 03 00             	movb   $0x0,(%ebx)
}
 1b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1b8:	5b                   	pop    %ebx
 1b9:	5e                   	pop    %esi
 1ba:	5f                   	pop    %edi
 1bb:	5d                   	pop    %ebp
 1bc:	c3                   	ret    
 1bd:	8d 76 00             	lea    0x0(%esi),%esi

000001c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c0:	f3 0f 1e fb          	endbr32 
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	56                   	push   %esi
 1c8:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c9:	83 ec 08             	sub    $0x8,%esp
 1cc:	6a 00                	push   $0x0
 1ce:	ff 75 08             	pushl  0x8(%ebp)
 1d1:	e8 ed 00 00 00       	call   2c3 <open>
  if(fd < 0)
 1d6:	83 c4 10             	add    $0x10,%esp
 1d9:	85 c0                	test   %eax,%eax
 1db:	78 2b                	js     208 <stat+0x48>
    return -1;
  r = fstat(fd, st);
 1dd:	83 ec 08             	sub    $0x8,%esp
 1e0:	ff 75 0c             	pushl  0xc(%ebp)
 1e3:	89 c3                	mov    %eax,%ebx
 1e5:	50                   	push   %eax
 1e6:	e8 f0 00 00 00       	call   2db <fstat>
  close(fd);
 1eb:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 1ee:	89 c6                	mov    %eax,%esi
  close(fd);
 1f0:	e8 b6 00 00 00       	call   2ab <close>
  return r;
 1f5:	83 c4 10             	add    $0x10,%esp
}
 1f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1fb:	89 f0                	mov    %esi,%eax
 1fd:	5b                   	pop    %ebx
 1fe:	5e                   	pop    %esi
 1ff:	5d                   	pop    %ebp
 200:	c3                   	ret    
 201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
 208:	be ff ff ff ff       	mov    $0xffffffff,%esi
 20d:	eb e9                	jmp    1f8 <stat+0x38>
 20f:	90                   	nop

00000210 <atoi>:

int
atoi(const char *s)
{
 210:	f3 0f 1e fb          	endbr32 
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	53                   	push   %ebx
 218:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21b:	0f be 02             	movsbl (%edx),%eax
 21e:	8d 48 d0             	lea    -0x30(%eax),%ecx
 221:	80 f9 09             	cmp    $0x9,%cl
  n = 0;
 224:	b9 00 00 00 00       	mov    $0x0,%ecx
  while('0' <= *s && *s <= '9')
 229:	77 1a                	ja     245 <atoi+0x35>
 22b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 22f:	90                   	nop
    n = n*10 + *s++ - '0';
 230:	83 c2 01             	add    $0x1,%edx
 233:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
 236:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
  while('0' <= *s && *s <= '9')
 23a:	0f be 02             	movsbl (%edx),%eax
 23d:	8d 58 d0             	lea    -0x30(%eax),%ebx
 240:	80 fb 09             	cmp    $0x9,%bl
 243:	76 eb                	jbe    230 <atoi+0x20>
  return n;
}
 245:	89 c8                	mov    %ecx,%eax
 247:	5b                   	pop    %ebx
 248:	5d                   	pop    %ebp
 249:	c3                   	ret    
 24a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000250 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 250:	f3 0f 1e fb          	endbr32 
 254:	55                   	push   %ebp
 255:	89 e5                	mov    %esp,%ebp
 257:	57                   	push   %edi
 258:	8b 45 10             	mov    0x10(%ebp),%eax
 25b:	8b 55 08             	mov    0x8(%ebp),%edx
 25e:	56                   	push   %esi
 25f:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 262:	85 c0                	test   %eax,%eax
 264:	7e 0f                	jle    275 <memmove+0x25>
 266:	01 d0                	add    %edx,%eax
  dst = vdst;
 268:	89 d7                	mov    %edx,%edi
 26a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    *dst++ = *src++;
 270:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 271:	39 f8                	cmp    %edi,%eax
 273:	75 fb                	jne    270 <memmove+0x20>
  return vdst;
}
 275:	5e                   	pop    %esi
 276:	89 d0                	mov    %edx,%eax
 278:	5f                   	pop    %edi
 279:	5d                   	pop    %ebp
 27a:	c3                   	ret    

0000027b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27b:	b8 01 00 00 00       	mov    $0x1,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <exit>:
SYSCALL(exit)
 283:	b8 02 00 00 00       	mov    $0x2,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <wait>:
SYSCALL(wait)
 28b:	b8 03 00 00 00       	mov    $0x3,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <pipe>:
SYSCALL(pipe)
 293:	b8 04 00 00 00       	mov    $0x4,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <read>:
SYSCALL(read)
 29b:	b8 05 00 00 00       	mov    $0x5,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <write>:
SYSCALL(write)
 2a3:	b8 10 00 00 00       	mov    $0x10,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <close>:
SYSCALL(close)
 2ab:	b8 15 00 00 00       	mov    $0x15,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <kill>:
SYSCALL(kill)
 2b3:	b8 06 00 00 00       	mov    $0x6,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <exec>:
SYSCALL(exec)
 2bb:	b8 07 00 00 00       	mov    $0x7,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <open>:
SYSCALL(open)
 2c3:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <mknod>:
SYSCALL(mknod)
 2cb:	b8 11 00 00 00       	mov    $0x11,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <unlink>:
SYSCALL(unlink)
 2d3:	b8 12 00 00 00       	mov    $0x12,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <fstat>:
SYSCALL(fstat)
 2db:	b8 08 00 00 00       	mov    $0x8,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <link>:
SYSCALL(link)
 2e3:	b8 13 00 00 00       	mov    $0x13,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <mkdir>:
SYSCALL(mkdir)
 2eb:	b8 14 00 00 00       	mov    $0x14,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <chdir>:
SYSCALL(chdir)
 2f3:	b8 09 00 00 00       	mov    $0x9,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <dup>:
SYSCALL(dup)
 2fb:	b8 0a 00 00 00       	mov    $0xa,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <getpid>:
SYSCALL(getpid)
 303:	b8 0b 00 00 00       	mov    $0xb,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <sbrk>:
SYSCALL(sbrk)
 30b:	b8 0c 00 00 00       	mov    $0xc,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <sleep>:
SYSCALL(sleep)
 313:	b8 0d 00 00 00       	mov    $0xd,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <uptime>:
SYSCALL(uptime)
 31b:	b8 0e 00 00 00       	mov    $0xe,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <waitx>:
//my insert begins
SYSCALL(waitx)
 323:	b8 16 00 00 00       	mov    $0x16,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <psinfo>:
SYSCALL(psinfo)
 32b:	b8 17 00 00 00       	mov    $0x17,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <set_priority>:
SYSCALL(set_priority)
 333:	b8 18 00 00 00       	mov    $0x18,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    
 33b:	66 90                	xchg   %ax,%ax
 33d:	66 90                	xchg   %ax,%ax
 33f:	90                   	nop

00000340 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	57                   	push   %edi
 344:	56                   	push   %esi
 345:	53                   	push   %ebx
 346:	83 ec 3c             	sub    $0x3c,%esp
 349:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 34c:	89 d1                	mov    %edx,%ecx
{
 34e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  if(sgn && xx < 0){
 351:	85 d2                	test   %edx,%edx
 353:	0f 89 7f 00 00 00    	jns    3d8 <printint+0x98>
 359:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 35d:	74 79                	je     3d8 <printint+0x98>
    neg = 1;
 35f:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
    x = -xx;
 366:	f7 d9                	neg    %ecx
  } else {
    x = xx;
  }

  i = 0;
 368:	31 db                	xor    %ebx,%ebx
 36a:	8d 75 d7             	lea    -0x29(%ebp),%esi
 36d:	8d 76 00             	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
 370:	89 c8                	mov    %ecx,%eax
 372:	31 d2                	xor    %edx,%edx
 374:	89 cf                	mov    %ecx,%edi
 376:	f7 75 c4             	divl   -0x3c(%ebp)
 379:	0f b6 92 60 07 00 00 	movzbl 0x760(%edx),%edx
 380:	89 45 c0             	mov    %eax,-0x40(%ebp)
 383:	89 d8                	mov    %ebx,%eax
 385:	8d 5b 01             	lea    0x1(%ebx),%ebx
  }while((x /= base) != 0);
 388:	8b 4d c0             	mov    -0x40(%ebp),%ecx
    buf[i++] = digits[x % base];
 38b:	88 14 1e             	mov    %dl,(%esi,%ebx,1)
  }while((x /= base) != 0);
 38e:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
 391:	76 dd                	jbe    370 <printint+0x30>
  if(neg)
 393:	8b 4d bc             	mov    -0x44(%ebp),%ecx
 396:	85 c9                	test   %ecx,%ecx
 398:	74 0c                	je     3a6 <printint+0x66>
    buf[i++] = '-';
 39a:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
 39f:	89 d8                	mov    %ebx,%eax
    buf[i++] = '-';
 3a1:	ba 2d 00 00 00       	mov    $0x2d,%edx

  while(--i >= 0)
 3a6:	8b 7d b8             	mov    -0x48(%ebp),%edi
 3a9:	8d 5c 05 d7          	lea    -0x29(%ebp,%eax,1),%ebx
 3ad:	eb 07                	jmp    3b6 <printint+0x76>
 3af:	90                   	nop
 3b0:	0f b6 13             	movzbl (%ebx),%edx
 3b3:	83 eb 01             	sub    $0x1,%ebx
  write(fd, &c, 1);
 3b6:	83 ec 04             	sub    $0x4,%esp
 3b9:	88 55 d7             	mov    %dl,-0x29(%ebp)
 3bc:	6a 01                	push   $0x1
 3be:	56                   	push   %esi
 3bf:	57                   	push   %edi
 3c0:	e8 de fe ff ff       	call   2a3 <write>
  while(--i >= 0)
 3c5:	83 c4 10             	add    $0x10,%esp
 3c8:	39 de                	cmp    %ebx,%esi
 3ca:	75 e4                	jne    3b0 <printint+0x70>
    putc(fd, buf[i]);
}
 3cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3cf:	5b                   	pop    %ebx
 3d0:	5e                   	pop    %esi
 3d1:	5f                   	pop    %edi
 3d2:	5d                   	pop    %ebp
 3d3:	c3                   	ret    
 3d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 3d8:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
 3df:	eb 87                	jmp    368 <printint+0x28>
 3e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 3e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 3ef:	90                   	nop

000003f0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3f0:	f3 0f 1e fb          	endbr32 
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	57                   	push   %edi
 3f8:	56                   	push   %esi
 3f9:	53                   	push   %ebx
 3fa:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3fd:	8b 75 0c             	mov    0xc(%ebp),%esi
 400:	0f b6 1e             	movzbl (%esi),%ebx
 403:	84 db                	test   %bl,%bl
 405:	0f 84 b4 00 00 00    	je     4bf <printf+0xcf>
  ap = (uint*)(void*)&fmt + 1;
 40b:	8d 45 10             	lea    0x10(%ebp),%eax
 40e:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 411:	8d 7d e7             	lea    -0x19(%ebp),%edi
  state = 0;
 414:	31 d2                	xor    %edx,%edx
  ap = (uint*)(void*)&fmt + 1;
 416:	89 45 d0             	mov    %eax,-0x30(%ebp)
 419:	eb 33                	jmp    44e <printf+0x5e>
 41b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 41f:	90                   	nop
 420:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 423:	ba 25 00 00 00       	mov    $0x25,%edx
      if(c == '%'){
 428:	83 f8 25             	cmp    $0x25,%eax
 42b:	74 17                	je     444 <printf+0x54>
  write(fd, &c, 1);
 42d:	83 ec 04             	sub    $0x4,%esp
 430:	88 5d e7             	mov    %bl,-0x19(%ebp)
 433:	6a 01                	push   $0x1
 435:	57                   	push   %edi
 436:	ff 75 08             	pushl  0x8(%ebp)
 439:	e8 65 fe ff ff       	call   2a3 <write>
 43e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      } else {
        putc(fd, c);
 441:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 444:	0f b6 1e             	movzbl (%esi),%ebx
 447:	83 c6 01             	add    $0x1,%esi
 44a:	84 db                	test   %bl,%bl
 44c:	74 71                	je     4bf <printf+0xcf>
    c = fmt[i] & 0xff;
 44e:	0f be cb             	movsbl %bl,%ecx
 451:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 454:	85 d2                	test   %edx,%edx
 456:	74 c8                	je     420 <printf+0x30>
      }
    } else if(state == '%'){
 458:	83 fa 25             	cmp    $0x25,%edx
 45b:	75 e7                	jne    444 <printf+0x54>
      if(c == 'd'){
 45d:	83 f8 64             	cmp    $0x64,%eax
 460:	0f 84 9a 00 00 00    	je     500 <printf+0x110>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 466:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 46c:	83 f9 70             	cmp    $0x70,%ecx
 46f:	74 5f                	je     4d0 <printf+0xe0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 471:	83 f8 73             	cmp    $0x73,%eax
 474:	0f 84 d6 00 00 00    	je     550 <printf+0x160>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 47a:	83 f8 63             	cmp    $0x63,%eax
 47d:	0f 84 8d 00 00 00    	je     510 <printf+0x120>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 483:	83 f8 25             	cmp    $0x25,%eax
 486:	0f 84 b4 00 00 00    	je     540 <printf+0x150>
  write(fd, &c, 1);
 48c:	83 ec 04             	sub    $0x4,%esp
 48f:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 493:	6a 01                	push   $0x1
 495:	57                   	push   %edi
 496:	ff 75 08             	pushl  0x8(%ebp)
 499:	e8 05 fe ff ff       	call   2a3 <write>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 49e:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 4a1:	83 c4 0c             	add    $0xc,%esp
 4a4:	6a 01                	push   $0x1
 4a6:	83 c6 01             	add    $0x1,%esi
 4a9:	57                   	push   %edi
 4aa:	ff 75 08             	pushl  0x8(%ebp)
 4ad:	e8 f1 fd ff ff       	call   2a3 <write>
  for(i = 0; fmt[i]; i++){
 4b2:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
        putc(fd, c);
 4b6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 4b9:	31 d2                	xor    %edx,%edx
  for(i = 0; fmt[i]; i++){
 4bb:	84 db                	test   %bl,%bl
 4bd:	75 8f                	jne    44e <printf+0x5e>
    }
  }
}
 4bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4c2:	5b                   	pop    %ebx
 4c3:	5e                   	pop    %esi
 4c4:	5f                   	pop    %edi
 4c5:	5d                   	pop    %ebp
 4c6:	c3                   	ret    
 4c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 4ce:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 16, 0);
 4d0:	83 ec 0c             	sub    $0xc,%esp
 4d3:	b9 10 00 00 00       	mov    $0x10,%ecx
 4d8:	6a 00                	push   $0x0
 4da:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 4dd:	8b 45 08             	mov    0x8(%ebp),%eax
 4e0:	8b 13                	mov    (%ebx),%edx
 4e2:	e8 59 fe ff ff       	call   340 <printint>
        ap++;
 4e7:	89 d8                	mov    %ebx,%eax
 4e9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ec:	31 d2                	xor    %edx,%edx
        ap++;
 4ee:	83 c0 04             	add    $0x4,%eax
 4f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
 4f4:	e9 4b ff ff ff       	jmp    444 <printf+0x54>
 4f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        printint(fd, *ap, 10, 1);
 500:	83 ec 0c             	sub    $0xc,%esp
 503:	b9 0a 00 00 00       	mov    $0xa,%ecx
 508:	6a 01                	push   $0x1
 50a:	eb ce                	jmp    4da <printf+0xea>
 50c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        putc(fd, *ap);
 510:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  write(fd, &c, 1);
 513:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 516:	8b 03                	mov    (%ebx),%eax
  write(fd, &c, 1);
 518:	6a 01                	push   $0x1
        ap++;
 51a:	83 c3 04             	add    $0x4,%ebx
  write(fd, &c, 1);
 51d:	57                   	push   %edi
 51e:	ff 75 08             	pushl  0x8(%ebp)
        putc(fd, *ap);
 521:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 524:	e8 7a fd ff ff       	call   2a3 <write>
        ap++;
 529:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 52c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 52f:	31 d2                	xor    %edx,%edx
 531:	e9 0e ff ff ff       	jmp    444 <printf+0x54>
 536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 53d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
 540:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 543:	83 ec 04             	sub    $0x4,%esp
 546:	e9 59 ff ff ff       	jmp    4a4 <printf+0xb4>
 54b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 54f:	90                   	nop
        s = (char*)*ap;
 550:	8b 45 d0             	mov    -0x30(%ebp),%eax
 553:	8b 18                	mov    (%eax),%ebx
        ap++;
 555:	83 c0 04             	add    $0x4,%eax
 558:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 55b:	85 db                	test   %ebx,%ebx
 55d:	74 17                	je     576 <printf+0x186>
        while(*s != 0){
 55f:	0f b6 03             	movzbl (%ebx),%eax
      state = 0;
 562:	31 d2                	xor    %edx,%edx
        while(*s != 0){
 564:	84 c0                	test   %al,%al
 566:	0f 84 d8 fe ff ff    	je     444 <printf+0x54>
 56c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 56f:	89 de                	mov    %ebx,%esi
 571:	8b 5d 08             	mov    0x8(%ebp),%ebx
 574:	eb 1a                	jmp    590 <printf+0x1a0>
          s = "(null)";
 576:	bb 58 07 00 00       	mov    $0x758,%ebx
        while(*s != 0){
 57b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 57e:	b8 28 00 00 00       	mov    $0x28,%eax
 583:	89 de                	mov    %ebx,%esi
 585:	8b 5d 08             	mov    0x8(%ebp),%ebx
 588:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 58f:	90                   	nop
  write(fd, &c, 1);
 590:	83 ec 04             	sub    $0x4,%esp
          s++;
 593:	83 c6 01             	add    $0x1,%esi
 596:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 599:	6a 01                	push   $0x1
 59b:	57                   	push   %edi
 59c:	53                   	push   %ebx
 59d:	e8 01 fd ff ff       	call   2a3 <write>
        while(*s != 0){
 5a2:	0f b6 06             	movzbl (%esi),%eax
 5a5:	83 c4 10             	add    $0x10,%esp
 5a8:	84 c0                	test   %al,%al
 5aa:	75 e4                	jne    590 <printf+0x1a0>
 5ac:	8b 75 d4             	mov    -0x2c(%ebp),%esi
      state = 0;
 5af:	31 d2                	xor    %edx,%edx
 5b1:	e9 8e fe ff ff       	jmp    444 <printf+0x54>
 5b6:	66 90                	xchg   %ax,%ax
 5b8:	66 90                	xchg   %ax,%ax
 5ba:	66 90                	xchg   %ax,%ax
 5bc:	66 90                	xchg   %ax,%ax
 5be:	66 90                	xchg   %ax,%ax

000005c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5c0:	f3 0f 1e fb          	endbr32 
 5c4:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c5:	a1 04 0a 00 00       	mov    0xa04,%eax
{
 5ca:	89 e5                	mov    %esp,%ebp
 5cc:	57                   	push   %edi
 5cd:	56                   	push   %esi
 5ce:	53                   	push   %ebx
 5cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5d2:	8b 10                	mov    (%eax),%edx
  bp = (Header*)ap - 1;
 5d4:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5d7:	39 c8                	cmp    %ecx,%eax
 5d9:	73 15                	jae    5f0 <free+0x30>
 5db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 5df:	90                   	nop
 5e0:	39 d1                	cmp    %edx,%ecx
 5e2:	72 14                	jb     5f8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5e4:	39 d0                	cmp    %edx,%eax
 5e6:	73 10                	jae    5f8 <free+0x38>
{
 5e8:	89 d0                	mov    %edx,%eax
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5ea:	8b 10                	mov    (%eax),%edx
 5ec:	39 c8                	cmp    %ecx,%eax
 5ee:	72 f0                	jb     5e0 <free+0x20>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f0:	39 d0                	cmp    %edx,%eax
 5f2:	72 f4                	jb     5e8 <free+0x28>
 5f4:	39 d1                	cmp    %edx,%ecx
 5f6:	73 f0                	jae    5e8 <free+0x28>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5f8:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5fb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5fe:	39 fa                	cmp    %edi,%edx
 600:	74 1e                	je     620 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 602:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 605:	8b 50 04             	mov    0x4(%eax),%edx
 608:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 60b:	39 f1                	cmp    %esi,%ecx
 60d:	74 28                	je     637 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 60f:	89 08                	mov    %ecx,(%eax)
  freep = p;
}
 611:	5b                   	pop    %ebx
  freep = p;
 612:	a3 04 0a 00 00       	mov    %eax,0xa04
}
 617:	5e                   	pop    %esi
 618:	5f                   	pop    %edi
 619:	5d                   	pop    %ebp
 61a:	c3                   	ret    
 61b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 61f:	90                   	nop
    bp->s.size += p->s.ptr->s.size;
 620:	03 72 04             	add    0x4(%edx),%esi
 623:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 626:	8b 10                	mov    (%eax),%edx
 628:	8b 12                	mov    (%edx),%edx
 62a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 62d:	8b 50 04             	mov    0x4(%eax),%edx
 630:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 633:	39 f1                	cmp    %esi,%ecx
 635:	75 d8                	jne    60f <free+0x4f>
    p->s.size += bp->s.size;
 637:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 63a:	a3 04 0a 00 00       	mov    %eax,0xa04
    p->s.size += bp->s.size;
 63f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 642:	8b 53 f8             	mov    -0x8(%ebx),%edx
 645:	89 10                	mov    %edx,(%eax)
}
 647:	5b                   	pop    %ebx
 648:	5e                   	pop    %esi
 649:	5f                   	pop    %edi
 64a:	5d                   	pop    %ebp
 64b:	c3                   	ret    
 64c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000650 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 650:	f3 0f 1e fb          	endbr32 
 654:	55                   	push   %ebp
 655:	89 e5                	mov    %esp,%ebp
 657:	57                   	push   %edi
 658:	56                   	push   %esi
 659:	53                   	push   %ebx
 65a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 65d:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 660:	8b 3d 04 0a 00 00    	mov    0xa04,%edi
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 666:	8d 70 07             	lea    0x7(%eax),%esi
 669:	c1 ee 03             	shr    $0x3,%esi
 66c:	83 c6 01             	add    $0x1,%esi
  if((prevp = freep) == 0){
 66f:	85 ff                	test   %edi,%edi
 671:	0f 84 a9 00 00 00    	je     720 <malloc+0xd0>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 677:	8b 07                	mov    (%edi),%eax
    if(p->s.size >= nunits){
 679:	8b 48 04             	mov    0x4(%eax),%ecx
 67c:	39 f1                	cmp    %esi,%ecx
 67e:	73 6d                	jae    6ed <malloc+0x9d>
 680:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
 686:	bb 00 10 00 00       	mov    $0x1000,%ebx
 68b:	0f 43 de             	cmovae %esi,%ebx
  p = sbrk(nu * sizeof(Header));
 68e:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
 695:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
 698:	eb 17                	jmp    6b1 <malloc+0x61>
 69a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6a0:	8b 10                	mov    (%eax),%edx
    if(p->s.size >= nunits){
 6a2:	8b 4a 04             	mov    0x4(%edx),%ecx
 6a5:	39 f1                	cmp    %esi,%ecx
 6a7:	73 4f                	jae    6f8 <malloc+0xa8>
 6a9:	8b 3d 04 0a 00 00    	mov    0xa04,%edi
 6af:	89 d0                	mov    %edx,%eax
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6b1:	39 c7                	cmp    %eax,%edi
 6b3:	75 eb                	jne    6a0 <malloc+0x50>
  p = sbrk(nu * sizeof(Header));
 6b5:	83 ec 0c             	sub    $0xc,%esp
 6b8:	ff 75 e4             	pushl  -0x1c(%ebp)
 6bb:	e8 4b fc ff ff       	call   30b <sbrk>
  if(p == (char*)-1)
 6c0:	83 c4 10             	add    $0x10,%esp
 6c3:	83 f8 ff             	cmp    $0xffffffff,%eax
 6c6:	74 1b                	je     6e3 <malloc+0x93>
  hp->s.size = nu;
 6c8:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 6cb:	83 ec 0c             	sub    $0xc,%esp
 6ce:	83 c0 08             	add    $0x8,%eax
 6d1:	50                   	push   %eax
 6d2:	e8 e9 fe ff ff       	call   5c0 <free>
  return freep;
 6d7:	a1 04 0a 00 00       	mov    0xa04,%eax
      if((p = morecore(nunits)) == 0)
 6dc:	83 c4 10             	add    $0x10,%esp
 6df:	85 c0                	test   %eax,%eax
 6e1:	75 bd                	jne    6a0 <malloc+0x50>
        return 0;
  }
}
 6e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 6e6:	31 c0                	xor    %eax,%eax
}
 6e8:	5b                   	pop    %ebx
 6e9:	5e                   	pop    %esi
 6ea:	5f                   	pop    %edi
 6eb:	5d                   	pop    %ebp
 6ec:	c3                   	ret    
    if(p->s.size >= nunits){
 6ed:	89 c2                	mov    %eax,%edx
 6ef:	89 f8                	mov    %edi,%eax
 6f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->s.size == nunits)
 6f8:	39 ce                	cmp    %ecx,%esi
 6fa:	74 54                	je     750 <malloc+0x100>
        p->s.size -= nunits;
 6fc:	29 f1                	sub    %esi,%ecx
 6fe:	89 4a 04             	mov    %ecx,0x4(%edx)
        p += p->s.size;
 701:	8d 14 ca             	lea    (%edx,%ecx,8),%edx
        p->s.size = nunits;
 704:	89 72 04             	mov    %esi,0x4(%edx)
      freep = prevp;
 707:	a3 04 0a 00 00       	mov    %eax,0xa04
}
 70c:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 70f:	8d 42 08             	lea    0x8(%edx),%eax
}
 712:	5b                   	pop    %ebx
 713:	5e                   	pop    %esi
 714:	5f                   	pop    %edi
 715:	5d                   	pop    %ebp
 716:	c3                   	ret    
 717:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 71e:	66 90                	xchg   %ax,%ax
    base.s.ptr = freep = prevp = &base;
 720:	c7 05 04 0a 00 00 08 	movl   $0xa08,0xa04
 727:	0a 00 00 
    base.s.size = 0;
 72a:	bf 08 0a 00 00       	mov    $0xa08,%edi
    base.s.ptr = freep = prevp = &base;
 72f:	c7 05 08 0a 00 00 08 	movl   $0xa08,0xa08
 736:	0a 00 00 
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 739:	89 f8                	mov    %edi,%eax
    base.s.size = 0;
 73b:	c7 05 0c 0a 00 00 00 	movl   $0x0,0xa0c
 742:	00 00 00 
    if(p->s.size >= nunits){
 745:	e9 36 ff ff ff       	jmp    680 <malloc+0x30>
 74a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        prevp->s.ptr = p->s.ptr;
 750:	8b 0a                	mov    (%edx),%ecx
 752:	89 08                	mov    %ecx,(%eax)
 754:	eb b1                	jmp    707 <malloc+0xb7>

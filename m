Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vergina.eng.auth.gr ([155.207.18.1]:53334 "EHLO
	vergina.eng.auth.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab0ITPjC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 11:39:02 -0400
Message-ID: <4C978008.50805@eng.auth.gr>
Date: Mon, 20 Sep 2010 18:38:48 +0300
From: George Mamalakis <mamalos@eng.auth.gr>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfsv3 gssapi client?
References: <4C938F3B.4030604@eng.auth.gr> <20100917174328.GC25515@fieldses.org> <4C972DB3.2050405@eng.auth.gr> <20100920145643.GD4580@fieldses.org>
In-Reply-To: <20100920145643.GD4580@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 20/09/2010 17:56, J. Bruce Fields wrote:
>
> Ouch.  Well, that's a problem.
>
> (And have you checked the log files to make sure it's gssd segfaulting
> and not some kind of crash in the kernel?)
>
> --b.
>

Yes, it segfaults, even the log shows it. It's a null pointer exception. 
I used gdb in gssd and this is my outcome:

0xb783f424 in __kernel_vsyscall ()
(gdb) c
Continuing.

Program received signal SIG37, Real-time event 37.
0xb783f424 in __kernel_vsyscall ()
(gdb) c
Continuing.

Program received signal SIG37, Real-time event 37.
0xb783f424 in __kernel_vsyscall ()
(gdb) c
Continuing.

Program received signal SIGSEGV, Segmentation fault.
0xb72b4c8e in __gss_get_mechanism_cred () from /usr/lib/libgssglue.so.1
(gdb) bt
#0  0xb72b4c8e in __gss_get_mechanism_cred () from /usr/lib/libgssglue.so.1
#1  0xb72b5c2c in gss_init_sec_context () from /usr/lib/libgssglue.so.1
#2  0xb776c215 in authgss_refresh () from /usr/lib/libtirpc.so.1
#3  0xb776c67d in authgss_create () from /usr/lib/libtirpc.so.1
#4  0xb776c779 in authgss_create_default () from /usr/lib/libtirpc.so.1
#5  0x0804cbdc in ?? ()
#6  0x0804cf9f in ?? ()
#7  0x0804d7c8 in ?? ()
#8  0x0804b7a8 in ?? ()
#9  0x0804b309 in ?? ()
#10 0xb761cc76 in __libc_start_main () from /lib/libc.so.6
#11 0x0804a621 in ?? ()
(gdb) info r
eax            0x0    0
ecx            0x9    9
edx            0x0    0
ebx            0xb72b9710    -1221880048
esp            0xbfe0b844    0xbfe0b844
ebp            0xbfe0b858    0xbfe0b858
esi            0x9    9
edi            0x9370928    154601768
eip            0xb72b4c8e    0xb72b4c8e <__gss_get_mechanism_cred+62>
eflags         0x210246    [ PF ZF IF RF ID ]
cs             0x73    115
ss             0x7b    123
ds             0x7b    123
es             0x7b    123
fs             0x0    0
gs             0x33    51
(gdb) disass $eip
Dump of assembler code for function __gss_get_mechanism_cred:
    0xb72b4c50 <+0>:    push   %ebp
    0xb72b4c51 <+1>:    mov    %esp,%ebp
    0xb72b4c53 <+3>:    push   %edi
    0xb72b4c54 <+4>:    push   %esi
    0xb72b4c55 <+5>:    sub    $0xc,%esp
    0xb72b4c58 <+8>:    mov    0x8(%ebp),%ecx
    0xb72b4c5b <+11>:    test   %ecx,%ecx
    0xb72b4c5d <+13>:    jne    0xb72b4c68 <__gss_get_mechanism_cred+24>
    0xb72b4c5f <+15>:    add    $0xc,%esp
    0xb72b4c62 <+18>:    xor    %eax,%eax
    0xb72b4c64 <+20>:    pop    %esi
    0xb72b4c65 <+21>:    pop    %edi
    0xb72b4c66 <+22>:    pop    %ebp
    0xb72b4c67 <+23>:    ret
    0xb72b4c68 <+24>:    mov    0x8(%ebp),%eax
    0xb72b4c6b <+27>:    mov    (%eax),%eax
    0xb72b4c6d <+29>:    test   %eax,%eax
    0xb72b4c6f <+31>:    mov    %eax,-0x10(%ebp)
    0xb72b4c72 <+34>:    jle    0xb72b4c5f <__gss_get_mechanism_cred+15>
    0xb72b4c74 <+36>:    mov    0xc(%ebp),%ecx
    0xb72b4c77 <+39>:    mov    0x8(%ebp),%eax
    0xb72b4c7a <+42>:    mov    (%ecx),%edx
    0xb72b4c7c <+44>:    mov    0x4(%eax),%eax
    0xb72b4c7f <+47>:    mov    %edx,-0x14(%ebp)
    0xb72b4c82 <+50>:    mov    %eax,-0xc(%ebp)
    0xb72b4c85 <+53>:    xor    %eax,%eax
    0xb72b4c87 <+55>:    nop
    0xb72b4c88 <+56>:    mov    -0xc(%ebp),%edx
    0xb72b4c8b <+59>:    mov    -0x14(%ebp),%ecx
=> 0xb72b4c8e <+62>:    cmp    (%edx,%eax,8),%ecx
    0xb72b4c91 <+65>:    jne    0xb72b4cab <__gss_get_mechanism_cred+91>
    0xb72b4c93 <+67>:    mov    0xc(%ebp),%edx
    0xb72b4c96 <+70>:    mov    -0xc(%ebp),%ecx
    0xb72b4c99 <+73>:    mov    0x4(%edx),%esi
    0xb72b4c9c <+76>:    mov    -0x14(%ebp),%edx
---Type <return> to continue, or q <return> to quit---q
Quit
(gdb) info r
eax            0x0    0
ecx            0x9    9
edx            0x0    0
ebx            0xb72b9710    -1221880048
esp            0xbfe0b844    0xbfe0b844
ebp            0xbfe0b858    0xbfe0b858
esi            0x9    9
edi            0x9370928    154601768
eip            0xb72b4c8e    0xb72b4c8e <__gss_get_mechanism_cred+62>
eflags         0x210246    [ PF ZF IF RF ID ]
cs             0x73    115
ss             0x7b    123
ds             0x7b    123
es             0x7b    123
fs             0x0    0
gs             0x33    51


Where you can see the null reference.

This, on the other hand, reminded me a discussion I had in the 
fbsd-stable list, where somebody advised me to use des-cbc-crc keytabs, 
and then experiment with other encryption types. Even though I didn't 
have such issues in fbsd, this might be the case on this problem. Maybe 
linux tries to compare an inexistent mech-type (or enc-type, whatever) 
with one of it's list, and hence it segfaults. So, to shed a little more 
light into the issue:

- the kdc (not the nfs-server) runs fbsd8, heimdal-1.2.1.
- on the linuxbox when I "kinit -k linuxclient" everything works fine.
- on the linux client "ktutil -k /etc/krb5.keytab list" shows:
/etc/krb5.keytab:

Vno  Type                     Principal                               
Aliases
   1  des-cbc-md5              host/linuxclient@EXAMPLE
   1  des-cbc-md4              host/linuxclient@EXAMPLE
   1  des-cbc-crc              host/linuxclient@EXAMPLE
   1  aes256-cts-hmac-sha1-96  host/linuxclient@EXAMPLE
   1  des3-cbc-sha1            host/linuxclient@EXAMPLE
   1  arcfour-hmac-md5         host/linuxclient@EXAMPLE

So maybe what I have to do next is to create a keytab of des-cbc-crc 
encryption-type only for the client (maybe also for the nfsserver as 
well..) and see how it'll behave...but I will do it tomorrow.

Until then,

mamalos

-- 
George Mamalakis

IT Officer
Electrical and Computer Engineer (Aristotle Un. of Thessaloniki),
MSc (Imperial College of London)

Department of Electrical and Computer Engineering
Faculty of Engineering
Aristotle University of Thessaloniki

phone number : +30 (2310) 994379


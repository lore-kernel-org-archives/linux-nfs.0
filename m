Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938467AbeBUQI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 11:08:57 -0500
Subject: Re: nfs-utils: rpc.svcgssd segmentation fault in
 nss_gss_princ_to_ids()
To: Matthias Gerstner <matthias.gerstner@nefkom.net>,
        linux-nfs@vger.kernel.org, Justin Mitchell <jumitche@redhat.com>
References: <20180220224858.GA14972@q910.gerrit.home>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <849cf544-ba0a-c218-020d-93f973ba7ab6@RedHat.com>
Date: Wed, 21 Feb 2018 11:08:48 -0500
MIME-Version: 1.0
In-Reply-To: <20180220224858.GA14972@q910.gerrit.home>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 02/20/2018 05:48 PM, Matthias Gerstner wrote:
> Hello!
> 
> I hope I have found the right place to report this.
It is... But in the future please in line your
patch (which I have a the bottom of this reply)
instead attaching it.. I just makes it easier 
to review.

> 
> I have recently upgraded from nfs-utils-1.3.4 to nfs-utils-2.3.1 on a Gentoo
> Linux (hardened) system. After this upgrade the rpc.svcgssd crashes on my
> kerberized NFS server each time a client tries to mount an NFS export.
The main difference in these releases is we rolled libnfsidmap into
nfs-utils... 

Also note, at least with Fedora, we no longer use rpc.svcgssd
instead we use gssproxy to access GSSAPI credentials

> 
> The crash is a segmentation fault:
> 
>   kernel: rpc.svcgssd[19772]: segfault at 8 ip 00007f6b6aafa98c sp 00007fff2ca8ce30 error 4 in nsswitch.so[7f6b6aaf9000+7000]
> 
> The call stack leading up to this looks as follows:
> 
>   (gdb) 
>   Program received signal SIGSEGV, Segmentation fault.
>   nss_gss_princ_to_ids (secname=<optimized out>, princ=0x55cabc7d9940 "nfs/host.example.domain@EXAMPLE.HOME", 
>       uid=0x7ffca550e0d8, gid=0x7ffca550e0dc, UNUSED_ex=<optimized out>) at nss.c:415
>   415	nss.c: No such file or directory.
> 
>   (gdb) bt
>   #0  nss_gss_princ_to_ids (secname=<optimized out>, princ=0x55cabc7d9940 "nfs/host.example.domain@EXAMPLE.HOME", 
>       uid=0x7ffca550e0d8, gid=0x7ffca550e0dc, UNUSED_ex=<optimized out>) at nss.c:415
>   #1  0x00007f6c97cc2886 in nfs4_gss_princ_to_ids (secname=secname@entry=0x55caba8e2030 <m2f+16> "krb5", 
>       princ=princ@entry=0x55cabc7d9940 "nfs/host.example.domain@EXAMPLE.HOME", uid=0x7ffca550e0d8, uid@entry=0x1, 
>       gid=0x7ffca550e0dc, gid@entry=0x7f6c95cf3a76 <conf_get_section+86>) at libnfsidmap.c:682
>   #2  0x000055caba6da138 in get_ids (cred=0x7ffca550e038, mech=<optimized out>, client_name=<optimized out>)
>       at svcgssd_proc.c:251
>   #3  handle_nullreq (f=f@entry=3) at svcgssd_proc.c:407
>   #4  0x000055caba6d996a in gssd_run () at svcgssd_main_loop.c:91
>   #5  0x000055caba6d83b1 in main (argc=1, argv=<optimized out>) at svcgssd.c:211
> 
>   (gdb) p realms
>   $1 = (struct conf_list *) 0x0
> 
> I debugged this a bit and strange things came about. There seem to be
> duplicate instances of the local_realms variable in the
> support/nfsidmap/nfsidmap_common.c compilation unit:
> 
>   gdb --args /usr/sbin/rpc.svcgssd  -f
>   (gdb) start
>   Temporary breakpoint 1 at 0x2170: file svcgssd.c, line 94.
>   Starting program: /usr/sbin/rpc.svcgssd -f
>   Temporary breakpoint 1, main (argc=2, argv=0x7fffffffddc8) at svcgssd.c:94
>   94	svcgssd.c: No such file or directory.
> 
>   (gdb) b get_local_realms 
>   Breakpoint 2 at 0x7ffff7bd1fc0: file nfsidmap_common.c, line 30.
>   (gdb) c
>   Continuing.
> 
>   Breakpoint 2, get_local_realms () at nfsidmap_common.c:30
>   30	nfsidmap_common.c: No such file or directory.
>   (gdb) disassemble 
>   Dump of assembler code for function get_local_realms:
>   => 0x00007ffff5e0b4a0 <+0>:	sub    $0x1038,%rsp
>      0x00007ffff5e0b4a7 <+7>:	orq    $0x0,(%rsp)
>      0x00007ffff5e0b4ac <+12>:	add    $0x1020,%rsp
>      0x00007ffff5e0b4b3 <+19>:	mov    %fs:0x28,%rax
>      0x00007ffff5e0b4bc <+28>:	mov    %rax,0x8(%rsp)
>      0x00007ffff5e0b4c1 <+33>:	xor    %eax,%eax
>      0x00007ffff5e0b4c3 <+35>:	mov    0x204f7e(%rip),%rax        # 0x7ffff6010448 <local_realms>
>      0x00007ffff5e0b4ca <+42>:	mov    0x8(%rsp),%rdx
>      0x00007ffff5e0b4cf <+47>:	xor    %fs:0x28,%rdx
>      0x00007ffff5e0b4d8 <+56>:	jne    0x7ffff5e0b4df <get_local_realms+63>
>      0x00007ffff5e0b4da <+58>:	add    $0x18,%rsp
>      0x00007ffff5e0b4de <+62>:	retq   
>      0x00007ffff5e0b4df <+63>:	callq  0x7ffff5e0a250 <__stack_chk_fail@plt>
> 
>   End of assembler dump.
> 
>   (gdb) p local_realms
>   $1 = (struct conf_list *) 0x555555764300
>   (gdb) p &local_realms
>   $2 = (struct conf_list **) 0x7ffff7dd7208 <local_realms>
> 
>   (gdb) x /1g 0x7ffff6010448
>   0x7ffff6010448 <local_realms>:	0x0000000000000000
> 
> So there's one instance of the variable that was actually assigned the
> expected data. And there's another one that is at NULL and returned from
> get_local_realms().
> 
> This is related to the "#pragma GCC visibility push(hidden)" in the
> compilation unit. Moving it after the local_realms variable declaration fixes
> the issue. I've attached a patch that does just this.
Nice work... BTW... 

> 
> I am not quite sure whether this is a compiler issue or an invalid use of the
> visibility hidden pragma. The compiler used is:
> 
>   gcc (Gentoo Hardened 6.4.0-r1 p1.3) 6.4.0
> 
> Please advise.
> 
> Regards
> 
> Matthias
> commit b1935a982aa68890ffe888381f7905f57c6b055d
> Author: Matthias Gerstner <Matthias.Gerstner@nefkom.net>
> Date:   Tue Feb 20 23:33:18 2018 +0100
>
>    get_local_realms: work around strange duplication of local_realms
>    
>    The hidden visibility seems to cause the get_local_realms() function to
>    return a NULL pointer, although the local_realms global variable is
>    actually assigned. Assembler code shows there are two instances of this
>    variable around, one set to NULL, the other to the expected value.
>    
>    This happened on Gentoo Hardened with gcc 4.6.0-r1.
>
> diff --git a/support/nfsidmap/nfsidmap_common.c b/support/nfsidmap/nfsidmap_common.c
> index 891c855..e5c33a8 100644
> --- a/support/nfsidmap/nfsidmap_common.c
> +++ b/support/nfsidmap/nfsidmap_common.c
> @@ -19,13 +19,13 @@
> #include "nfsidmap_plugin.h"
> #include "conffile.h"
> 
> -#pragma GCC visibility push(hidden)
> -
>  int reformat_group = 0;
>  int no_strip = 0;
> 
>  struct conf_list *local_realms;
>  
> +#pragma GCC visibility push(hidden)
By moving this pragama statement both the no_strip 
and reformat_group are also being exposed as 
global variables in the libnfsidmap, correct?
I'm not sure we want to do that, if that is the case.

I guess exposing local_realms is necessary
but it is adding to the API... which is probably
not good...

steved. 
> +
>  struct conf_list *get_local_realms(void)
>  {
 	return local_realms;



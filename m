Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61376 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753948Ab2CMUjC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 16:39:02 -0400
Message-ID: <4F5FB04B.9040200@netapp.com>
Date: Tue, 13 Mar 2012 16:38:35 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Rahul Katariya <katariya.rahul@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs locking with cent os 6?
References: <CANhbJ3XhN8r3hT9xpng44=pa18sx1jj_=p0_+Az+zV5F6WjAyw@mail.gmail.com>
In-Reply-To: <CANhbJ3XhN8r3hT9xpng44=pa18sx1jj_=p0_+Az+zV5F6WjAyw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/13/2012 04:21 PM, Rahul Katariya wrote:

>  Hi ,
> 
> I am using Cent OS 6 64 bit which supports NFS version 4.


A few questions:

- What kernel version is Cent OS 6 using?  I'm running 3.2.7 (on Archlinux, though) and those tests pass...
- Is the server Cent OS 6, too?
- Do you still get the warnings if you run with -f instead of -t?
- Have you tried increasing your "timeo" value?  7 seems somewhat low...

My `mount` output looks like this:
davros:/home/bjschuma/ on /nfs type nfs (rw,relatime,vers=3,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.122.1,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.122.1)


- Bryan

> 
> I ran cthon-nfs-tests on it.
> 
> Although NFS version is 4 supported, I am using NFS 3 for mounting NFS share.
> 
> Following are packages installed.
> # rpm -qa |grep nfs
> nfs-utils-1.2.2-7.el6.x86_64
>  nfs-utils-lib-1.1.5-1.el6.x86_64
> 
>  Mount shows following
>  # mount
>  nfs-server:/export/share/connectathon on /nfstestdir1 type nfs
> (rw,intr,retrans=5,timeo=7,tcp,nfsvers=3,rsize=8192,wsize=8192,addr=10.10.10.1)
> 
> Following is a nfs locking testcase result:
> 
> [lock]$  ./runtests   -t /nfstestdir1
> Starting LOCKING tests: test directory  (arg: -t)
> 
>  Testing native post-LFS locking
> 
>  Creating parent/child synchronization pipes.
>  =======================================================
>  Test #1 - Test regions of an unlocked file.
>          Parent: 1.1  - F_TEST  [       0,       1] PASSED.
>          Parent: 1.2  - F_TEST  [       0,  ENDING] PASSED.
>          Parent: 1.3  - F_TEST  [       0,7fffffff] PASSED.
>          Parent: 1.4  - F_TEST  [       1,       1] PASSED.
>          Parent: 1.5  - F_TEST  [       1,  ENDING] PASSED.
>          Parent: 1.6  - F_TEST  [       1,7fffffff] PASSED.
>          Parent: 1.7  - F_TEST  [7fffffff,       1] PASSED.
>          Parent: 1.8  - F_TEST  [7fffffff,  ENDING] PASSED.
>          Parent: 1.9  - F_TEST  [7fffffff,7fffffff] WARNING!
>          Parent: **** Expected EOVERFLOW, returned success...
> 
>  Test #2 - Try to lock the whole file.
>          Parent: 2.0  - F_TLOCK [       0,  ENDING] PASSED.
>          Child:  2.1  - F_TEST  [       0,       1] PASSED.
>          Child:  2.2  - F_TEST  [       0,  ENDING] PASSED.
>          Child:  2.3  - F_TEST  [       0,7fffffff] PASSED.
>          Child:  2.4  - F_TEST  [       1,       1] PASSED.
>          Child:  2.5  - F_TEST  [       1,  ENDING] PASSED.
>          Child:  2.6  - F_TEST  [       1,7fffffff] PASSED.
>          Child:  2.7  - F_TEST  [7fffffff,       1] PASSED.
>          Child:  2.8  - F_TEST  [7fffffff,  ENDING] PASSED.
>          Child:  2.9  - F_TEST  [7fffffff,7fffffff] WARNING!
>          Child:  **** Expected EOVERFLOW, returned EACCES...
>          Parent: 2.10 - F_ULOCK [       0,  ENDING] PASSED.
> 
>  Test #6 - Try to lock the MAXEOF byte.
>          Parent: 6.0  - F_TLOCK [7fffffff,       1] PASSED.
>          Child:  6.1  - F_TEST  [7ffffffe,       1] PASSED.
>          Child:  6.2  - F_TEST  [7ffffffe,       2] PASSED.
>          Child:  6.3  - F_TEST  [7ffffffe,  ENDING] PASSED.
>          Child:  6.4  - F_TEST  [7fffffff,       1] PASSED.
>          Child:  6.5  - F_TEST  [7fffffff,       2] WARNING!
>          Child:  **** Expected EOVERFLOW, returned EACCES...
>          Child:  6.6  - F_TEST  [7fffffff,  ENDING] PASSED.
>          Child:  6.7  - F_TEST  [80000000,  ENDING] PASSED.
>          Child:  6.8  - F_TEST  [80000000,       1] PASSED.
>          Child:  6.9  - F_TEST  [80000000,7fffffff] PASSED.
>          Child:  6.10 - F_TEST  [80000000,80000000] PASSED.
>          Parent: 6.11 - F_ULOCK [7fffffff,       1] PASSED.
> 
>  =======================================================
> 
>   Test#1 , Test#2  and Test#6  Shows warning in locking .. i.e.
> Expected .something. and returned some-other-thing ..
> 
> Are these locking well-known issues?
> 
> Are there any patch available for the same?  Are these serious warnings?
> 
> Thanks,
> Rahul
> ¢éì¹»®&Þ~º&¶¬-+-±éÝ¶¥Sw®zË>±Êâmébzìg~È§¶>¡Ü¨}©z²Æ zÚ&j:+v?¨¾«'êçzZ+?Ê+zf£¢·hs^§~?­?Ûiÿûàz¹®w¥¢¸?T¨è­Ú&¢)ß¢f



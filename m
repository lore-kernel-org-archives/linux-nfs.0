Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:50946 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752784AbeE3NoW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 09:44:22 -0400
Received: by mail-it0-f68.google.com with SMTP id p3-v6so23178092itc.0
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 06:44:21 -0700 (PDT)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <0dae4862d6e5b754ba8f90a6391b6645fdf6889a.camel@gmail.com>
Subject: Re: Is "unmount -f"  worked as expected?
To: "Shawn Lu (shawlu)" <shawlu@cisco.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 30 May 2018 08:44:19 -0500
In-Reply-To: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
References: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-05-30 at 00:38 +0000, Shawn Lu (shawlu) wrote:
> Dear Maintainers of NFS:
> 
>   I need help to better understand behavior of “-f” option
> for  “umount” NFS file system.  Here is what I got from   Man page
> (  https://linux.die.net/man/8/umount) :
> 
>  “ -f Force unmount (in case of an unreachable NFS system). (Requires
> kernel 2.1.116 or later.)” 
> 
> My interpretation of Man page is “umount –f”  should able to force
> umount nfs when NFS server is not available. 
> 
> On my test, I am observed “umount –f”  is not always work as
> expected.  Also there some behavior difference on  “umount –f “ with
> regarding to different NFS version.  
> Here is my experiment on 4.4 Kernel ( I am believe this is true for
> latest kernel):
>   Test for nfsv3:
> a)  From Host A, Start NFS server and export “/shared” directory
> ,which has only my file test.txt
> b)  from Host B,   remote mount  host A:/shared to    /test  using
> nfsv3
> c)  from host B  open file /test/test.txt
> d) from host B,  do  “umount –f  /test“,  it returns “device is busy”
> e) From host A ,  do following “rm  -f /etc/exports ; touch
> /etc/exports ; exportfs -ra”
> f) From host B ,    do  “umount –f  /test“,  it returns “device is
> busy”
> g) Reboot HOST A
> h) From host B:  do  “umount –f  /test“  succeed. 
> 
>  Test for nfsv4:
> i)	 From Host A, Start NFS server and export “/shared”
> directory ,which has only my file test.txt
> j)	 from Host B,   remote mount  host A:/shared
> to    /test  using nfsv4
> k)	 from host B  open file /test/test.txt
> l)	from host B,  do  “umount –f  /test“,  it returns “device
> is busy”
> m)	From host A ,  do following “rm  -f /etc/exports ; touch
> /etc/exports ; exportfs -ra”
> n)	From host B ,    do  “umount –f  /test“,  it returns
> “device is busy”
> o)	Reboot NFS server( HOST A)
> p)	From host B:  do  “umount –f  /test“  ,  still return
> “device is busy”
>    
> 
> For both nfsv3 and nfsv4,  “umount –f “ will fails even the super
> block is already “staled”(check step f and step n) .  “-f” option for
> NFSv4 is more “broken” since now it will not succeed even with NFS
> server off line.  
> 
> Here my questions:
> 1. If “umount –f “  can’t force unmount “staled ” nfs mount ,   How
> it differential itself from regular umount (without –f)?  
> 2. is  “-f”  option is “broken” for NFSv4 or it is intend behavior to
> fail “umount –f” even Server is offline ?   

I'm not an NFS maintainer, but I had a very similar question a few
months ago and even wrote some patches to try and get a more "forceful"
unmount. Unfortunately, I got distracted with other tasks and haven't
looped around to finish the job. You can read through the lengthy
discussion and patches here:

Initial Discussion:
https://www.spinics.net/lists/linux-nfs/msg66073.html

RFC Patches:
https://www.spinics.net/lists/linux-nfs/msg66348.html
https://www.spinics.net/lists/linux-nfs/msg66421.html
https://www.spinics.net/lists/linux-nfs/msg66466.html
https://www.spinics.net/lists/linux-nfs/msg66483.html

Hopefully, that helps. If you are interested in reviving this work, I
am still interested and would be willing to help out.

> 
> Really appreciate if someone in the mailing list can help to answer
> my dumb questions. 
> 
> 
> Thanks,
> Shawn 
> 
> 
> 
> 
> 
> 
> NrybXǧv^)޺{.n+{"^nrzh&Gh(階ݢj"mzޖfh~m

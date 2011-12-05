Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50377 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab1LEXd6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 18:33:58 -0500
Message-ID: <1323128020.7237.3.camel@lade.trondhjem.org>
Subject: Re: Help wanted: ENOCLK returned during lock test#2 in
 connectathon's test
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Mon, 05 Dec 2011 18:33:40 -0500
In-Reply-To: <4EDCCC89.6080205@cea.fr>
References: <4EDCCC89.6080205@cea.fr>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-12-05 at 14:52 +0100, DENIEL Philippe wrote: 
> Hi,
> 
> as you may know (we may have met at Bake-A-Thon), I am working on 
> NFS-Ganesha, a NFS server running in userspace. I currently face an 
> issue when running cthon04 test suite, during the "lock step".
> Client is linux 3.1.0-rc4, server is nfs-ganesha compiled with FSAL_VFS 
> support. Server is mounted via command "mount 
> -overs=4.minorversion=1,lock <server>:<path> /mnt"
> 
> During the test#2 in "lock" tests, I got the following error:
> 
>     Creating parent/child synchronization pipes.
> 
>     Test #2 - Try to lock the whole file.
>             Parent: 2.0  - F_TLOCK [               0,          ENDING]
>     FAILED!
>             Parent: **** Expected success, returned errno=37...
>             Parent: **** Probably implementation error.
> 
>     ** PARENT pass 1 results: 0/0 pass, 0/0 warn, 1/1 fail (pass/total).
> 
>     **  CHILD pass 1 results: 0/0 pass, 0/0 warn, 0/0 fail (pass/total).
> 
> 
> I made a wireshark capture of the packet (see attachement). Apparently, 
> the client does 2 compounds, one for OP4_OPEN and a second to call 
> OP4_OPEN_CONFIRM.

Hi Philippe,

As far as I can see from the pcap file, your server isn't setting the
OPEN4_RESULT_LOCKTYPE_POSIX flag in the OPEN reply, and so the client
can't support posix locking semantics. In that case, it will return
ENOLCK to all fcntl locking requests.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


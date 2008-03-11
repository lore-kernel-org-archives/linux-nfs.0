From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mail corruption with async mounts NFSv3
Date: Tue, 11 Mar 2008 15:54:25 -0400
Message-ID: <1205265265.15431.5.camel@heimdal.trondhjem.org>
References: <200803111859.m2BIxiKC001883@cs.utexas.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Fletcher Mattox <fletcher-NZpS4cJIG2HvQtjrzfazuQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:57618 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbYCKTy3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2008 15:54:29 -0400
In-Reply-To: <200803111859.m2BIxiKC001883-NZpS4cJIG2HvQtjrzfazuQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-03-11 at 13:59 -0500, Fletcher Mattox wrote:
> Hi
> 
> We deliver mail via NFS to a NetApp file server.  After many trouble
> free years, we are suddenly and frequently seeing corrupted mailboxes.
> We usually see a series of NUL bytes (10 to 2000+) prepended to the
> message (i.e. immediately in front of the From_ line).  Our local
> delivery agent is procmail.  It is configured to lock files via
> dotlock only, no kernel based file locking.  After obtaining a lock,
> procmail does this, before writing:
> 
>         fd   = open(mailbox,O_WRONLY|O_APPEND|O_CREAT,perm);
>         last = lseek(fd,(off_t)0,SEEK_END);
> 
> My experience with procmail has been positive.  It goes to great
> trouble to do correct locking over NFS (within the limits of the
> protocol, of course).
> 
> We use NFSv3 on a 2.6.19.1 kernel with this entry in /etc/mtab:

That is very likely to be the same problem as fixed in

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=5d47a35600270e7115061cb1320ee60ae9bcb6b8

AFAICR, all kernels after 2.6.17 were affected. Can you therefore see if
the same patch applies to 2.6.19, and if it fixes your problem?

Cheers
  Trond


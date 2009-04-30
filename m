Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39739 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761824AbZD3VXU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2009 17:23:20 -0400
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Brian R Cowan <brcowan@us.ibm.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <49FA0CE8.9090706@redhat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
Content-Type: text/plain
Date: Thu, 30 Apr 2009 17:23:07 -0400
Message-Id: <1241126587.15476.62.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-04-30 at 16:41 -0400, Peter Staubach wrote:
> Chuck Lever wrote:
> >
> > On Apr 30, 2009, at 4:12 PM, Brian R Cowan wrote:
> >>
> >> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ab0a3dbedc51037f3d2e22ef67717a987b3d15e2
> >>
> Actually, the "stable" part can be a killer.  It depends upon
> why and when nfs_flush_inode() is invoked.
> 
> I did quite a bit of work on this aspect of RHEL-5 and discovered
> that this particular code was leading to some serious slowdowns.
> The server would end up doing a very slow FILE_SYNC write when
> all that was really required was an UNSTABLE write at the time.
> 
> Did anyone actually measure this optimization and if so, what
> were the numbers?

As usual, the optimisation is workload dependent. The main type of
workload we're targetting with this patch is the app that opens a file,
writes < 4k and then closes the file. For that case, it's a no-brainer
that you don't need to split a single stable write into an unstable + a
commit.

So if the application isn't doing the above type of short write followed
by close, then exactly what is causing a flush to disk in the first
place? Ordinarily, the client will try to cache writes until the cows
come home (or until the VM tells it to reclaim memory - whichever comes
first)...

Cheers
  Trond


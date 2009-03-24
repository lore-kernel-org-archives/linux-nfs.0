From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Tue, 24 Mar 2009 17:19:17 -0400
Message-ID: <20090324211917.GJ19389@fieldses.org>
References: <49C93526.70303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52934 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbZCXVTW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 17:19:22 -0400
In-Reply-To: <49C93526.70303@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 24, 2009 at 03:31:50PM -0400, Peter Staubach wrote:
> Hi.
> 
> Attached is a patch which implements some flow control for the
> NFS client to control dirty pages.  The flow control is
> implemented on a per-file basis and causes dirty pages to be
> written out when the client can detect that the application is
> writing in a serial fashion and has dirtied enough pages to
> fill a complete over the wire transfer.
> 
> This work was precipitated by working on a situation where a
> server at a customer site was not able to adequately handle
> the behavior of the Linux NFS client.  This particular server
> required that all data to the file written to the file be
> written in a strictly serial fashion.  It also had problems
> handling the Linux NFS client semantic of caching a large
> amount of data and then sending out that data all at once.
> 
> The sequential ordering problem was resolved by a previous
> patch which was submitted to the linux-nfs list.  This patch
> addresses the capacity problem.
> 
> The problem is resolved by sending WRITE requests much
> earlier in the process of the application writing to the file.
> The client keeps track of the number of dirty pages associated
> with the file and also the last offset of the data being
> written.  When the client detects that a full over the wire
> transfer could be constructed and that the application is
> writing sequentially, then it generates an UNSTABLE write to
> server for the currently dirty data.
> 
> The client also keeps track of the number of these WRITE
> requests which have been generated.  It flow controls based
> on a configurable maximum.  This keeps the client from
> completely overwhelming the server.
> 
> A nice side effect of the framework is that the issue of
> stat()'ing a file being written can be handled much more
> quickly than before.  The amount of data that must be
> transmitted to the server to satisfy the "latest mtime"
> requirement is limited.  Also, the application writing to
> the file is blocked until the over the wire GETATTR is
> completed.  This allows the GETATTR to be send and the
> response received without competing with the data being
> written.
> 
> No performance regressions were seen during informal
> performance testing.
> 
> As a side note -- the more natural model of flow control
> would seem to be at the client/server level instead of
> the per-file level.  However, that level was too coarse
> with the particular server that was required to be used
> because its requirements were at the per-file level.

I don't understand what you mean by "its requirements were at the
per-file level".

> The new functionality in this patch is controlled via the
> use of the sysctl, nfs_max_outstanding_writes.  It defaults
> to 0, meaning no flow control and the current behaviors.
> Setting it to any non-zero value enables the functionality.
> The value of 16 seems to be a good number and aligns with
> other NFS and RPC tunables.
> 
> Lastly, the functionality of starting WRITE requests sooner
> to smooth out the i/o pattern should probably be done by the
> VM subsystem.  I am looking into this, but in the meantime
> and to solve the immediate problem, this support is proposed.

It seems unfortunate if we add a sysctl to work around a problem that
ends up being fixed some other way a version or two later.

Would be great to have some progress on these problems, though....

--b.

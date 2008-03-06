From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] asynchronous unlock on exit
Date: Thu, 06 Mar 2008 15:58:49 -0500
Message-ID: <1204837130.15601.14.camel@heimdal.trondhjem.org>
References: <47D05757.30002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:44012 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935786AbYCFU6z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2008 15:58:55 -0500
In-Reply-To: <47D05757.30002@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-06 at 15:43 -0500, Peter Staubach wrote:
> Hi.
> 
> In the course of investigating testing failures in the locking phase of the
> Connectathon testsuite, I discovered a couple of things.  One was that one
> of the tests in the locking tests was racy when it didn't seem to need to be
> and two, that the NFS client asynchronously releases locks when a process is
> exiting.
> 
> I developed a patch for the testsuite locking test and am working to try to
> find a way to get it included into the generally available testsuite.
> 
> The harder problem is that the NFS client kernel code asynchronously 
> releasing
> locks when a process is exiting.  I presume that this was added so that a
> process, which was holding locks when a server goes down, can be completely
> killed.  This sounds good, but leads to several problems.
> 
> The Single UNIX Specification Version 3 specifies that:  "All locks 
> associated
> with a file for a given process shall be removed when a file descriptor 
> for that
> file is closed by that process or the process holding that file descriptor
> terminates.".
> 
> This does not specify whether those locks must be released prior to the
> completion of the exit processing for the process or not.  However, general
> assumptions seem to be that those locks will be released.  This leads to 
> more
> deterministic behavior under normal circumstances.
> 
> The test, test12(), in the Connectathon locking tests, tests the assumption
> that if a process is holding a lock and gets signaled with a signal that 
> causes
> it to be killed, that it releases its lock.  The file, which was locked, can
> then be successfully locked by another process.
> 
> After further analysis, it appears that only the NFSv2 and NFSv3 clients
> release locks asynchronously when a process is exiting.  The NFSv4 client
> releases any locks synchronously.
> 
> I would propose to make all three versions match and to modify the 
> NFSv2/NFSv3
> behavior to match the NFSv4 behavior.  The attached patch implements 
> this change.

Hi Peter,

It looks to me as if that the approach you've chosen would basically
return us to the old problem that locks don't get cleaned up on the
server if/when someone sends the client process a fatal signal. I think
a better approach would be to take the one used in NFSv4 of keeping the
RPC call asynchronous, and then having the client wait for it to
complete.

Typically, the way you would do this is to convert nlmclnt_unlock to use
rpc_run_task(), so that you can recover a reference to the rpc_task
pointer and then use rpc_wait_for_completion_task() to wait for the RPC
call to complete.

Cheers
  Trond


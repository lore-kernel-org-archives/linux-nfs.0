From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/2] asynchronous unlock on exit
Date: Fri, 28 Mar 2008 18:08:15 -0400
Message-ID: <1206742095.15567.44.camel@heimdal.trondhjem.org>
References: <20080328201229.18158.52437.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <47ED6534.9080604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758994AbYC1WIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 18:08:18 -0400
In-Reply-To: <47ED6534.9080604@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-28 at 17:37 -0400, Peter Staubach wrote:

> However, I think that nlmclnt_unlock() needs to wait until
> the RPC is completed.

It should do that now. See the call to rpc_wait_for_completion_task() in
nlm_async_call()

>   The original problem was test12() in
> the Connectathon testsuite, which would occasionally fail.
> It would fail because the parent would kill the child process
> (actually the child of the child) and immediately attempt to
> grab the lock.  This would fail because the child hadn't
> completed releasing the lock yet.  There were some timing
> dependencies in test12() itself, which I eliminated, but then
> discovered that this wouldn't solve the entire problem.  (I
> can send you the new version of test12(), if you wish.)

So, at least in 2.6.25, the call to rpc_wait_for_completion_task() will
exit only on a fatal signal. The problem in test12() is that there is a
'pre-existing condition', in that the parent signalled us with a SIGINT,
and so the signal is set upon entry to the function.

IOW: we might have to perform a similar trick to what do_coredump()
does, and clear the TIF_SIGPENDING flag. I'm not sure if that is
sufficient, but given that we're eliminating the calls to
recalc_sigpending(), and that there should be no such calls left in the
RPC code, I think we're OK.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

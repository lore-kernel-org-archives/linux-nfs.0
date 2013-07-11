Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932323Ab3GKLN2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jul 2013 07:13:28 -0400
Date: Thu, 11 Jul 2013 07:13:46 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: corruption due to loss of lock
Message-ID: <20130711071346.03b946bd@corrin.poochiereds.net>
In-Reply-To: <20130613184737.GA25713@us.ibm.com>
References: <20130613184737.GA25713@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 13 Jun 2013 13:47:37 -0500
Malahal Naineni <malahal@us.ibm.com> wrote:

> Hi Trond,
> 
> I saw Bryan's patches here https://patchwork.kernel.org/patch/987402/
> that fix issues after loss of a lock.  What is the status on this patch
> set? Do they need more work? We have an application that uses range
> locks on a file. Two threads from two different clients end up writing
> to the same a file due to this bug after a lease expiry from a client.
> 
> Regards, Malahal.

(cc'ing Bryan since he did the original set)

Yeah, this set would be a nice thing to have. A couple of comments:

- I still think it would be best to make SIGLOST its own signal, but as
  Bryan points out, it would need to be larger than SIGRTMAX. I'm
  not sure that's possible on all arches with the way the RT signals
  were done. It's probably worth investigating that though before
  settling on SIGIO since it would be hard to change that retroactively.

- This is not really a v4.1 specific thing. It should also be done for
  v4.0 and v2/3, though the latter two really need to be done within
  lockd.
-- 
Jeff Layton <jlayton@redhat.com>

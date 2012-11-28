Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57292 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638Ab2K1UB2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 15:01:28 -0500
Date: Wed, 28 Nov 2012 15:01:26 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: Re: NFSd in container - it works
Message-ID: <20121128200126.GA17875@fieldses.org>
References: <50B64628.4070007@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B64628.4070007@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 28, 2012 at 09:13:12PM +0400, Stanislav Kinsbursky wrote:
> Hi.
> I have about ~10 more patches, which makes NFS server works in container (mnt + pid + net namesapces). And it passes basic tests.

Good, congratulations.

> But there are some issues I would like to discuss:
> 1) NFSd threads are running in init_pid namespace. This makes
> impossible to stop NFS server by signals from container.

Note "rpc.nfsd 0" (which writes to /proc/fs/nfsd/threads) is what
current Fedora, for example, uses to shut down the server.

It's not ideal, but for now we can tell people "if you're in a container
and want to shut down nfsd, you need to use /proc/fs/nfsd/threads, not
signals."

> Also is
> makes possible to stop and destroy container without stopping its
> NFS server (network namespace thus will stay alive). So, there
> should be implemented some way to destroy these threads, when
> container's child reaper is exiting.
> 2) We need to solve this issue with registering in wrong portmapper.
> Sync connects suits both Lockd and NFSd. Bruce, what about gss
> daemon? Maybe some other socket (abstract UNIX or loopback) can be
> used instead? Or PipeFS?

My vague thought was that the gss-proxy can do a write to a special file
to indicate that it's up (and thus that it should be used and not the
old svcgssd interface), and that we could use that process context to do
the connect....  Not sure if that works.

> 3) Holding net by tracker looks redundant. What was the reason for this?

I don't understand, what's tracker?

--b.

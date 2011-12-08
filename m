Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37421 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545Ab1LHRpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 12:45:05 -0500
Date: Thu, 8 Dec 2011 12:45:01 -0500
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: linux-image: on nfs4 server: RPC: AUTH_GSS upcall timed out
 Please check user daemon is running
Message-ID: <20111208174501.GA30088@fieldses.org>
References: <8762hrozdl.fsf@fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8762hrozdl.fsf@fifthhorseman.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2011 at 10:29:42AM -0500, Daniel Kahn Gillmor wrote:
> Hello Linux-NFS folks--
> 
> I've got an nfs4 server running linux kernel 3.1.1 with nfs-utils 1.2.4.
> 
> When an NFSv4 client connects to the server using sec=krb5p, the kernel
> emits:
> 
> [ 3505.754807] RPC: AUTH_GSS upcall timed out.
> [ 3505.754810] Please check user daemon is running.
> 
> It's true, i don't have rpc.gssd running on the server (though i do have
> rpc.svcgssd running).
> 
> But the client can go ahead and mount the filesystem anyway, and users
> with the appropriate krb5 credentials on the clients can access files on
> the server based on their credentials.
> 
> So it's not clear to me what this warning is about.   Should i be
> running rpc.gssd on the nfs server?

Yes, if you're using NFSv4 then the client and server should each run
both daemons.

> If so, what functionality am i losing out on by not running it?

You lose NFSv4.0 delegations, which depend on the ability for the server
to contact the client to send delegation recalls.  Delegations are
optional, so you won't lose correctness, but you may lose some
performance.

If you're using only v2, v3, or v4.1, that doesn't matter.  (v2 and v3
lack delegations, and v4.1 sends callbacks over existing
client-established connections).

> If i don't need to run it, why is the kernel emitting this message?

Nevertheless I have seen that message even on machines that were running
both daemons, so I suspect there's a bug here; I haven't made it a
priority to track it down since I haven't seen it cause any actual
problems.

--b.

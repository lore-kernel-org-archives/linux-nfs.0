From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors
  during connect
Date: Tue, 08 Apr 2008 18:28:26 -0400
Message-ID: <EXNANE01xEdt74gPfNS00000269@exnane01.hq.netapp.com>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net>
 <1207677612.11699.14.camel@heimdal.trondhjem.org>
 <EXNANE01j2iihlMWBLY00000265@exnane01.hq.netapp.com>
 <1207679743.11699.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21071 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736AbYDHW2k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 18:28:40 -0400
In-Reply-To: <1207679743.11699.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
References: <20080408173602.21776.60671.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <1207677612.11699.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <EXNANE01j2iihlMWBLY00000265-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <1207679743.11699.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:35 PM 4/8/2008, Trond Myklebust wrote:
>The only justification for passing more errors up to the higher layers
>is if they have different error handling requirements.
>The reason why we currently transform more or less everything into
>ENOTCONN is because the two other errors ECONNRESET and ECONNREFUSED
>basically require the same kind of error handling (exit with EIO in the
>"soft" case, and keep retrying in the "hard" case).
>
>So, what kind of RDMA errors are these, and how are we failing to handle
>them correctly today?

Actually, I think I replied to the wrong message - I meant to reply to
the leak, not the error! But yes, the RDMA transport needs to return
the "right" error - I just wish there were a betterlist. At one point I
believe xprtrdma returned EINVAL (because the rdma connection code
returned it to us), and the mount command helpfully printed "internal
error". I.e., it was valid, but not useful.

Tom.


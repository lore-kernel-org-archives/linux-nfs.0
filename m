Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36130 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932367AbaGUPXD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2014 11:23:03 -0400
Date: Mon, 21 Jul 2014 11:23:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] svcrdma: Select NFSv4.1 backchannel transport based on
 forward channel
Message-ID: <20140721152302.GC8438@fieldses.org>
References: <20140716193542.7847.95868.stgit@klimt.1015granger.net>
 <20140717183621.GA30442@fieldses.org>
 <9D651FDC-7C11-476A-AE50-746E6E37B3E2@oracle.com>
 <99240537-8EC8-4ED3-8574-B95AC8A42F56@oracle.com>
 <20140718191256.GB12801@fieldses.org>
 <F69F9045-6ECC-4210-837C-2837AF37D7ED@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F69F9045-6ECC-4210-837C-2837AF37D7ED@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2014 at 03:27:10PM -0400, Chuck Lever wrote:
> On Jul 18, 2014, at 3:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Either that or send the original CREATE_SESSION over the connection you
> > want used for the backchannel, then send a BIND_CONNECTION_TO_SESSION
> > over the RDMA connection.
> > 
> > That said, if the server knows there's no connection at all that's
> > available for the backchannel, then yes I agree that it should be
> > setting the PATH_DOWN flag:
> 
> I’m trying a fix that sets cl_cb_state = NFSD4_CB_DOWN in
> init_session() if SESSION4_BACK_CHAN is clear.
> 
> From the looks of it, the server is architected to support one and
> only one session per client ID. Is that correct?  Thus it expects
> just one CREATE_SESSION operation per EXCHANGE_ID. Does the server
> enforce this?

No, that would definitely be a bug, if you see it failing to support
multiple sessions per client id, let me know.

BUT we definitely only use one backchannel connection at a time, even if
the client offers us multiple connections over multiple sessions.

> Seems like cl_cb_state really should be a per-session thing for
> NFSv4.1.

All we care about is whether some session has a working backchannel.

The only callback we currently use is CB_RECALL, and it doesn't matter
which session that's sent over.  If we needed to support e.g.
CB_RECALL_SLOT, I think this should change.

> And, while we’re at it, the server should assert
> SEQ4_STATUS_CB_PATH_DOWN_SESSION as well as SEQ4_STATUS_CB_PATH_DOWN.

Looking back at the spec, especially the language about retrying
callbacsk, I think you might be right.  (And then maybe we do need to
track callback status per-session.)  I'm not sure if this has much
practical effect for now.

> > Yes, agreed, I'll take a look--how are you reproducing?
> 
> Prototype Linux client that doesn’t set SESSION4_BACK_CHAN when it does
> CREATE_SESSION. Preparing it for RDMA support.
> 
> You could code a pyNFS test.

OK.  I may not get to this very soon.

> > The
> > nfsd4_probe_callback() should result in NFSD4_CB_DOWN getting set as
> > soon as the workqueue process it.
> 
> Clearing SESSION4_BACK_CHAN squelches nfsd4_probe_callback(), so
> the server never checks in this case.

Oops, you're right.  May as well make that unconditional.

> > In theory there's a race there (I
> > should fix that) in practice I'd normally expect that to run before we
> > process a SEQUENCE request on the new session.
> 
> >> Do you remember what this commit was trying to fix?
> > 
> > It's not a bugfix, just a minor optimization.  We could revert it if
> > need be.
> 
> NP, I just don’t see how it helps to make that assumption, plus it
> doesn’t seem entirely safe.
> 
> My initial question was "why does alloc_client() initialize cl_cb_state
> to NFSD4_CB_UNKNOWN instead of NFSD4_CB_DOWN?”

I don't remember, it could be that we really only need two states.

--b.

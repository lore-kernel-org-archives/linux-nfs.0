Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40761 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932138AbaGRTM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2014 15:12:57 -0400
Date: Fri, 18 Jul 2014 15:12:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] svcrdma: Select NFSv4.1 backchannel transport based on
 forward channel
Message-ID: <20140718191256.GB12801@fieldses.org>
References: <20140716193542.7847.95868.stgit@klimt.1015granger.net>
 <20140717183621.GA30442@fieldses.org>
 <9D651FDC-7C11-476A-AE50-746E6E37B3E2@oracle.com>
 <99240537-8EC8-4ED3-8574-B95AC8A42F56@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <99240537-8EC8-4ED3-8574-B95AC8A42F56@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2014 at 02:47:41PM -0400, Chuck Lever wrote:
> 
> On Jul 17, 2014, at 2:59 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > 
> > On Jul 17, 2014, at 2:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> >> On Wed, Jul 16, 2014 at 03:38:32PM -0400, Chuck Lever wrote:
> >>> The current code always selects XPRT_TRANSPORT_BC_TCP for the back
> >>> channel, even when the forward channel was not TCP (eg, RDMA). When
> >>> a 4.1 mount is attempted with RDMA, the server panics in the TCP BC
> >>> code when trying to send CB_NULL.
> >>> 
> >>> Instead, construct the transport protocol number from the forward
> >>> channel transport or'd with XPRT_TRANSPORT_BC. Transports that do
> >>> not support bi-directional RPC will not have registered a "BC"
> >>> transport, causing create_backchannel_client() to fail immediately.
> >>> 
> >>> Fixes: https://bugzilla.linux-nfs.org/show_bug.cgi?id=265
> >>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>> ---
> >>> Hi Bruce-
> >>> 
> >>> What do you think of this approach?
> >> 
> >> OK by me.  (So clients use a separate tcp connection for the
> >> backchannel?)
> > 
> > Right.
> > 
> > The current plan is that, for NFSv4.1 over RDMA, the Linux client will
> > create an additional TCP connection and bind it to the same session as
> > the RDMA transport.
> > 
> > The TCP connection will be used solely for callback operations.  The
> > forward channel on that connection will not be used, except for
> > BIND_CONN_TO_SESSION operations.
> 
> Hi Bruce, pursuant to this goal, I’m trying to understand commit
> 14a24e99, especially the interior comment:
> 
> 3114 /* Should we give out recallable state?: */
> 3115 static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
> 3116 {
> 3117         if (clp->cl_cb_state == NFSD4_CB_UP)
> 3118                 return true;
> 3119         /*
> 3120          * In the sessions case, since we don't have to establish a
> 3121          * separate connection for callbacks, we assume it's OK
> 3122          * until we hear otherwise:
> 3123          */
> 3124         return clp->cl_minorversion && clp->cl_cb_state == NFSD4_CB_UNKNOWN;
> 3125 }
> 
> I wonder if that’s a valid assumption?
> 
> A separate virtual connection _does_ have to be established. If the
> client sent a CREATE_SESSION operation with the SESSION4_BACK_CHAN flag
> set, the server must verify that the client has an active bi-directional
> RPC service on the transport.

If the client sets the BACK_CHAN flag, that means it wants that
connection to be used as a back channel.

So in the RDMA case it sounds like the client needs to clear that flag
on the create session.

Either that or send the original CREATE_SESSION over the connection you
want used for the backchannel, then send a BIND_CONNECTION_TO_SESSION
over the RDMA connection.

That said, if the server knows there's no connection at all that's
available for the backchannel, then yes I agree that it should be
setting the PATH_DOWN flag:

> Otherwise it can hand out recallable state
> to a client with no callback service. Is that always safe?
> 
> Or, if the client sent a CREATE_SESSION operation with the
> SESSION4_BACK_CHAN flag cleared, then either the client intends not to
> set up a backchannel, or it intends to establish a separate transport
> for the backchannel. There is no backchannel in that case until the
> client establishes it.
> 
> Right now, if the client does not set SESSION4_BACK_CHAN, the server
> never asserts SEQ4_STATUS_CB_PATH_DOWN, even though there is no
> backchannel. That seems like a (minor, perhaps) bug.

Yes, agreed, I'll take a look--how are you reproducing?  The
nfsd4_probe_callback() should result in NFSD4_CB_DOWN getting set as
soon as the workqueue process it.  In theory there's a race there (I
should fix that) in practice I'd normally expect that to run before we
process a SEQUENCE request on the new session.

> Do you remember what this commit was trying to fix?

It's not a bugfix, just a minor optimization.  We could revert it if
need be.

--b.

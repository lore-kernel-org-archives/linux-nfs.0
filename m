From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
Date: Fri, 7 Nov 2008 06:23:52 -0500
Message-ID: <7225594ED4A1304C9E43D030A886D2215523B2@daytona.int.panasas.com>
References: <273FE88A07F5D445824060902F70034402A336FB@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "NFS list" <linux-nfs@vger.kernel.org>,
	"pNFS Mailing List" <pnfs@linux-nfs.org>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:27094 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751895AbYKGLaK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Nov 2008 06:30:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: Labiaga, Ricardo [mailto:Ricardo.Labiaga@netapp.com]
> > From: Benny Halevy [mailto:bhalevy@panasas.com]
> 
> [snip]
> 
> > >>> Ricardo,
> > >>>
> > >>> rpc_run_bc_task sets no task_setup_data.rpc_client when calling
> > >>> rpc_new_task.
> > >>> We might be able to use to fore channel rpc client,
> > >> We could, though it would cause the reconnection to occur in the
> > >> backchannel code path.  Haven't thought it through, but it sounds
> > >> cleaner to rebind the session (or reset it if the server went away) in
> > >> the forechannel context.  I wonder if it would be acceptable to simply
> >> drop the backchannel request, and have the forechannel reestablish the
> > >> connection (on a retransmission)?
> > >>
> > >>> but
> > >>> I'm still concerned that using this path for sending the callback
> > >>> replies is wrong.
> > >> The mainline RPC call_transmit() is already able to deal with RPC
> > >> transmissions that don't expect a reply.  This is pretty similar to
> > >> sending a reply, so we're leveraging the existing rpc_xprt.
> > >>
> > >> One alternative could be to construct an svc_xprt for the backchannel
> > >> and use svc_send() for the reply.  I wonder if it's really a better
> > >> approach since we already have the rpc_xprt available.
> > >
> > > I failed to mention that with the existing approach we're able to
> > > synchronize forechannel calls and backchannel replies on the rpc_xprt
> > > (XPRT_LOCKED bit).  It uses the synchronization mechanism already in
> > > mainline to prevent mixing the payload of requests and replies.
> >
> > Right, but we need to do this at the xprt layer.  I don't think that
> > this mandates starting the reply process from the rpc layer
> > as we do today in bc_send.
> >
> > Note that bc_svc_process gets both an rpc_rqst and a svc_rqst.
> > Although we forge a svc_rqst including setting up its rq_xprt
> > which is a svc_xprt, I'm not sure what exactly it is used for.
> 
> Correct, we build the svc_rqst so that we can use it in the processing
> of the backchannel request.  This way we reuse all of the existing v4
> backchannel logic for decoding, authenticating, dispatching, and result
> checking in svc_process_common().
> 
> > Eventually, we end up sending the reply (via bc_send) using
> > the rpc_rqst and its associated rpc_xprt.  This will allow
> > us to synchronize properly on the bi-directional channel.
> 
> If we really want to avoid the RPC state machine, I guess we could first
> serialize on the rpc_rqst by calling test_and_set_bit(XPRT_LOCKED,
> &xprt->state) to ensure no outgoing RPC grabs the transport.  We then
> issue the reply using svc_send() with the svc_rqst.  This does avoid
> having to copy the send buffer into the rpc_rqst, avoid building an
> rpc_task, and avoid entering the RPC state machine, though it requires
> an extra synchronization on the svc_xprt.xpt_mutex. 
> 
> Is this along the lines of what you're thinking?  I can give it a try...
 
Yes, absolutely.  One thing that came to me is that is would make
sense to encapsulate the xprt synchronization primitives in a few
helper functions implemnted at the xprt layer so that we won't
have to expose the internal implementation to the caller...
 
Benny

> 
> - ricardo
> 


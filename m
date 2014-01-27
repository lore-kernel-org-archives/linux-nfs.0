Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753413AbaA0XI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jan 2014 18:08:56 -0500
Date: Mon, 27 Jan 2014 18:08:50 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/5] NFSD/SUNRPC: Check rpc_xprt out of  xs_setup_bc_tcp
Message-ID: <20140127230850.GC8534@fieldses.org>
References: <20140106184926.GC31764@fieldses.org>
 <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com>
 <20140106225346.GB3342@fieldses.org>
 <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com>
 <52CB8B79.6040907@gmail.com>
 <52CE7A76.3080101@gmail.com>
 <52CE7AE6.4010603@gmail.com>
 <20140109162633.GB14308@fieldses.org>
 <C9F998C3-4A55-4714-926A-29440DF6F914@primarydata.com>
 <52CF5DD4.3080409@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <52CF5DD4.3080409@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies, I completely dropped this and now I've lost the thread of the
discussion.

What is your most recent patchset?

--b.

On Fri, Jan 10, 2014 at 10:41:24AM +0800, Kinglong Mee wrote:
> On 01/10/2014 01:27 AM, Trond Myklebust wrote:
> > 
> > On Jan 9, 2014, at 11:26, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> > 
> >> On Thu, Jan 09, 2014 at 06:33:10PM +0800, Kinglong Mee wrote:
> >>> Besides checking rpc_xprt out of xs_setup_bc_tcp,
> >>> increase it's reference (it's important).
> >>
> >> This sounds wrong to me: the presence of a backchannel can't prevent the
> >> client's connection from going away.  Instead, when the connection dies,
> >> any associated backchannels should be immediately destroyed.
> > 
> > Hi Bruce,
> > 
> > The right way to deal with this is to have knfsd shut down the rpc_client
> > when it detects the TCP disconnection event. 
> 
> Yes, that's right.
> Knfsd has do it as you said.
> 
> When getting xprt's status of XPT_CLOSE in svc_recv/svc_handle_xprt, 
> knfsd will delete the xprt by svc_delete_xprt.
> 
> In svc_delete_xprt, knfsd calls call_xpt_users to notify those users of the xprt.
> So, nfsd4_conn_lost will be called to free the connection.
> After freeing connection, nfsd4_probe_callback will update the callback for the client.
> And, the clp->cl_cb_client will be shutdown in nfsd4_process_cb_update.
> 
> At last, all using of the xprt will be released.
> I have test it, that's OK. 
> 
> > The xprt->count shouldn’t be an issue here: 
> > it has nothing to do with the socket connection state.
> 
> The xprt of backchannel, there are two references, 
> 1. rpc_clnt
> 2. svc_xprt
> 
> For rpc_clnt, initialize the xprt->count in xs_setup_bc_tcp,
> or increase it in create_backchannel_client, and, decrease in rpc_free_client.
> 
> For svc_xprt, increase it in xs_setup_bc_tcp, and decrease in svc_xprt_free.
> 
> thanks,
> Kinglong Mee
> 

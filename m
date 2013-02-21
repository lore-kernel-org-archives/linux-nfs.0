Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab3BUVhe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 16:37:34 -0500
Date: Thu, 21 Feb 2013 16:37:31 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "simo@redhat.com" <simo@redhat.com>
Subject: Re: [PATCH 5/6] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20130221213731.GG3531@pad.fieldses.org>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
 <1361464705-12340-6-git-send-email-bfields@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA682@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA682@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2013 at 06:35:46PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-02-21 at 11:38 -0500, J. Bruce Fields wrote:
> > +int gssp_accept_sec_context_upcall(struct net *net,
> > +				struct gssp_upcall_data *data)
> > +{
> > +	struct gssx_arg_accept_sec_context arg;
> > +	struct gssx_res_accept_sec_context res;
> > +	struct gssx_ctx ctxh;
> > +	struct gssx_ctx rctxh;
> > +	struct gssx_cred delegcred;
> > +	struct rpc_message msg = {
> > +		.rpc_proc = &gssp_procedures[GSSX_ACCEPT_SEC_CONTEXT],
> > +		.rpc_argp = &arg,
> > +		.rpc_resp = &res,
> > +		.rpc_cred = NULL, /* FIXME ? */
> > +	};
> > +	struct xdr_netobj client_name = { 0 , NULL };
> > +	int ret;
> > +
> > +	/* fill in arg */
> > +	memset(&arg, 0, sizeof(arg));
> > +	if (data->in_handle.len != 0) {
> > +		memset(&ctxh, 0, sizeof(ctxh));
> > +		arg.context_handle = &ctxh;
> > +		ctxh.state = data->in_handle;
> > +	}
> > +	arg.input_token = data->in_token;
> > +
> > +	/* use nfs/ for targ_name ? */
> > +
> > +	/* prepare res */
> > +	memset(&res, 0, sizeof(res));
> > +	memset(&rctxh, 0, sizeof(rctxh));
> > +	res.context_handle = &rctxh;
> > +
> > +	/* pass in the max length we expect for each of these
> > +	 * buffers but let the xdr code kmalloc them */
> > +	rctxh.exported_context_token.len = GSSX_max_output_handle_sz;
> > +	rctxh.mech.len = GSSX_max_oid_sz;
> > +	rctxh.src_name.display_name.len = GSSX_max_princ_sz;
> > +
> > +	res.output_token = &data->out_token;
> > +	res.output_token->len = GSSX_max_output_token_sz;
> 
> 
> C99 initialisers for arg, and res would clean this up nicely... Main
> question is how much stack does all the above eat?

It's about 1k, yuch.  I don't think that's going to cause problems here
in practice, but I'll see if I can trim it down, at least some of it
doesn't look like it's really used.

> > +static int gssx_dec_buffer(struct xdr_stream *xdr,
> > +			   gssx_buffer *buf)
> > +{
> > +	u32 length;
> > +	__be32 *p;
> > +
> > +	p = xdr_inline_decode(xdr, 4);
> > +	if (unlikely(p == NULL))
> > +		return -ENOSPC;
> > +
> > +	length = be32_to_cpup(p);
> > +	p = xdr_inline_decode(xdr, length);
> 
> combine for efficiency with the 4 byte allocation above.

I don't understand what you're asking for.  If you're suggesting a
single xdr_inline_decode(xdr, 4 + length)--I don't see how we can do
that with the length not known yet.

--b.

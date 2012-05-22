Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5923 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759208Ab2EVPPY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 11:15:24 -0400
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <20120522150221.GD891@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
	 <1337087550-9821-4-git-send-email-simo@redhat.com>
	 <20120522150221.GD891@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 May 2012 11:15:22 -0400
Message-ID: <1337699722.16840.189.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-22 at 11:02 -0400, J. Bruce Fields wrote:
> On Tue, May 15, 2012 at 09:12:29AM -0400, Simo Sorce wrote:
> > +/* numbers somewhat arbitrary but large enough for current needs */
> > +#define GSSX_MAX_OUT_HANDLE	128
> > +#define GSSX_MAX_MECH_OID	16
> > +#define GSSX_MAX_SRC_PRINC	256
> > +#define GSSX_KMEMBUF (GSSX_max_output_handle_sz + \
> > +			GSSX_max_oid_sz + \
> > +			GSSX_max_princ_sz + \
> > +			sizeof(struct svc_cred))
> > +
> ...
> > +	data->kmembuf = kmalloc(GSSX_KMEMBUF, GFP_KERNEL);
> ...
> > +	rctxh.exported_context_token.data = data->kmembuf;
> ...
> > +	rctxh.mech.data = data->kmembuf + GSSX_max_output_handle_sz;
> ...
> > +	rctxh.src_name.display_name.data = data->kmembuf +
> > +						GSSX_max_output_handle_sz +
> > +						GSSX_max_oid_sz;
> ...
> > +	data->creds = data->kmembuf +
> > +				GSSX_max_output_handle_sz +
> > +				GSSX_max_oid_sz +
> > +				GSSX_max_princ_sz;
> 
> Sorry, is this did I complaining about too many kmalloc()'s? 

Yes, you complained about kmallocs, so I did this instead :)

>  This seems
> likely to break in subtle ways if we ever change one of those constants
> to not be a multiple of a large enough power of 2.  And makes the memory
> handling a little more obscure.  I'd rather just allocate those
> separately if that's the choice.

I do not see why it would break, the only limit we have is the total
size of the kmembuf.

> But why not just include this in gssp_upcall_data?:
>  
>  struct gssp_upcall_data {
> -	void *kmembuf;
>  	struct xdr_netobj in_handle;
>  	struct gssp_in_token in_token;
>  	struct xdr_netobj out_handle;
> +	char out_handle_data[GSSX_MAX_OUT_HANDLE];
>  	struct xdr_netobj out_token;
>  	struct xdr_netobj mech_oid;
> +	char mech_oid_data[GSSX_MAX_MECH_OID];
>  	struct xdr_netobj client_name;
> +	char client_name_data[GSSX_MAX_SRC_PRINC];
> -	struct svc_cred *creds;
> +	struct svc_cred creds;
>  	int major_status;
>  	int minor_status;
>  };
> 
> As long as that still comes to under 4k that should be OK.

I did not want to do this to avoid users of the struct starting to rely
on those sizes, exactly to avoid having subtle issues later on if we
need to change them (unlikely).

> Oh, I see, and you'd have to alloc/free this in svcauth_gss_proxy_init
> instead of here, to avoid putting it on the stack there.

Right, plus it increases the stack size, and I really did not want to do
that.

> Whatever, I don't really care how the various xdr_netobj->data's are
> allocated, honestly there's no crusade to eliminate kmalloc()'s, I'll
> only object in a case (like the struct svc_cred field above) where it
> seems obviously unnecessary.

Ok, so what should I do ?
I can remove the static allocation and let the code allocate the data
with kmalloc, in the xdr unmarshalling code.
Whatever you like best.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York


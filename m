Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36875 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759156Ab2EVPCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 11:02:22 -0400
Date: Tue, 22 May 2012 11:02:21 -0400
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20120522150221.GD891@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
 <1337087550-9821-4-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337087550-9821-4-git-send-email-simo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 09:12:29AM -0400, Simo Sorce wrote:
> +/* numbers somewhat arbitrary but large enough for current needs */
> +#define GSSX_MAX_OUT_HANDLE	128
> +#define GSSX_MAX_MECH_OID	16
> +#define GSSX_MAX_SRC_PRINC	256
> +#define GSSX_KMEMBUF (GSSX_max_output_handle_sz + \
> +			GSSX_max_oid_sz + \
> +			GSSX_max_princ_sz + \
> +			sizeof(struct svc_cred))
> +
...
> +	data->kmembuf = kmalloc(GSSX_KMEMBUF, GFP_KERNEL);
...
> +	rctxh.exported_context_token.data = data->kmembuf;
...
> +	rctxh.mech.data = data->kmembuf + GSSX_max_output_handle_sz;
...
> +	rctxh.src_name.display_name.data = data->kmembuf +
> +						GSSX_max_output_handle_sz +
> +						GSSX_max_oid_sz;
...
> +	data->creds = data->kmembuf +
> +				GSSX_max_output_handle_sz +
> +				GSSX_max_oid_sz +
> +				GSSX_max_princ_sz;

Sorry, is this did I complaining about too many kmalloc()'s?  This seems
likely to break in subtle ways if we ever change one of those constants
to not be a multiple of a large enough power of 2.  And makes the memory
handling a little more obscure.  I'd rather just allocate those
separately if that's the choice.

But why not just include this in gssp_upcall_data?:
 
 struct gssp_upcall_data {
-	void *kmembuf;
 	struct xdr_netobj in_handle;
 	struct gssp_in_token in_token;
 	struct xdr_netobj out_handle;
+	char out_handle_data[GSSX_MAX_OUT_HANDLE];
 	struct xdr_netobj out_token;
 	struct xdr_netobj mech_oid;
+	char mech_oid_data[GSSX_MAX_MECH_OID];
 	struct xdr_netobj client_name;
+	char client_name_data[GSSX_MAX_SRC_PRINC];
-	struct svc_cred *creds;
+	struct svc_cred creds;
 	int major_status;
 	int minor_status;
 };

As long as that still comes to under 4k that should be OK.

Oh, I see, and you'd have to alloc/free this in svcauth_gss_proxy_init
instead of here, to avoid putting it on the stack there.

Whatever, I don't really care how the various xdr_netobj->data's are
allocated, honestly there's no crusade to eliminate kmalloc()'s, I'll
only object in a case (like the struct svc_cred field above) where it
seems obviously unnecessary.

--b.

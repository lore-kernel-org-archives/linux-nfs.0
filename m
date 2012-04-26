Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759129Ab2DZUHn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:07:43 -0400
Message-ID: <4F99AB01.3060203@RedHat.com>
Date: Thu, 26 Apr 2012 16:07:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Nick Alcock <nix@esperi.org.uk>
CC: linux-nfs@vger.kernel.org, Nick Alcock <nick.alcock@oracle.com>
Subject: Re: [PATCH 4/4] Fix debugging-related namespace pollution.
References: <1328472138-25750-1-git-send-email-nix@esperi.org.uk> <1328472138-25750-4-git-send-email-nix@esperi.org.uk>
In-Reply-To: <1328472138-25750-4-git-send-email-nix@esperi.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2012 03:02 PM, Nick Alcock wrote:
> From: Nick Alcock <nick.alcock@oracle.com>
> 
> When GSS is compiled in, libtirpc exports three symbols, 'log_debug',
> 'log_status', and 'log_hexdump', which do nothing unless DEBUG is #defined at
> libtirpc compile time. This is a pretty abominable piece of namespace pollution:
> these symbols are quite likely to be used for local debugging routines by other
> binaries and shared libraries, and those local calls are now likely to go astray
> into libtirpc's do-nothing versions instead.
> 
> So this changes the names of these functions. This is technically an ABI break,
> but since these symbols are undocumented and useless (with variable behaviour
> depending on whether DEBUG was #defined, and only present at all if GSS was
> compiled in) anything using those symbols was broken anyway.
> 
> (A quick grep of my local sources shows numerous other local users of the name
> log_debug() in particular, including LVM, libassuan, GnuPG, gvfs, and dhcp.
> If you include binaries as well as intra-shared-library calls, the count goes
> much higher.)
> 
> Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
> ---
>  src/auth_gss.c       |   46 ++++++++++++++++----------------
>  src/authgss_prot.c   |   70 +++++++++++++++++++++++++-------------------------
>  src/svc_auth_gss.c   |   58 ++++++++++++++++++++--------------------
>  tirpc/rpc/auth_gss.h |    6 ++--
>  4 files changed, 90 insertions(+), 90 deletions(-)
> 
> diff --git a/src/auth_gss.c b/src/auth_gss.c
> index a992049..539101e 100644
> --- a/src/auth_gss.c
> +++ b/src/auth_gss.c
> @@ -87,9 +87,9 @@ print_rpc_gss_sec(struct rpc_gss_sec *ptr)
>  int i;
>  char *p;
>  
> -	log_debug("rpc_gss_sec:");
> +	gss_log_debug("rpc_gss_sec:");
>  	if(ptr->mech == NULL)
> -		log_debug("NULL gss_OID mech");
> +		gss_log_debug("NULL gss_OID mech");
>  	else {
>  		fprintf(stderr, "     mechanism_OID: {");
>  		p = (char *)ptr->mech->elements;
> @@ -151,7 +151,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
>  	struct rpc_gss_data	*gd;
>  	OM_uint32		min_stat = 0;
>  
> -	log_debug("in authgss_create()");
> +	gss_log_debug("in authgss_create()");
>  
>  	memset(&rpc_createerr, 0, sizeof(rpc_createerr));
>  
> @@ -216,7 +216,7 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
>  	gss_buffer_desc		 sname;
>  	gss_name_t		 name = GSS_C_NO_NAME;
>  
> -	log_debug("in authgss_create_default()");
> +	gss_log_debug("in authgss_create_default()");
>  
>  
>  	sname.value = service;
> @@ -227,7 +227,7 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
>  		&name);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_import_name", maj_stat, min_stat);
> +		gss_log_status("gss_import_name", maj_stat, min_stat);
>  		rpc_createerr.cf_stat = RPC_AUTHERROR;
>  		return (NULL);
>  	}
> @@ -249,7 +249,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
>  {
>  	struct rpc_gss_data	*gd;
>  
> -	log_debug("in authgss_get_private_data()");
> +	gss_log_debug("in authgss_get_private_data()");
>  
>  	if (!auth || !pd)
>  		return (FALSE);
> @@ -269,7 +269,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
>  static void
>  authgss_nextverf(AUTH *auth)
>  {
> -	log_debug("in authgss_nextverf()");
> +	gss_log_debug("in authgss_nextverf()");
>  	/* no action necessary */
>  }
>  
> @@ -283,7 +283,7 @@ authgss_marshal(AUTH *auth, XDR *xdrs)
>  	OM_uint32		 maj_stat, min_stat;
>  	bool_t			 xdr_stat;
>  
> -	log_debug("in authgss_marshal()");
> +	gss_log_debug("in authgss_marshal()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> @@ -318,7 +318,7 @@ authgss_marshal(AUTH *auth, XDR *xdrs)
>  			    &rpcbuf, &checksum);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_get_mic", maj_stat, min_stat);
> +		gss_log_status("gss_get_mic", maj_stat, min_stat);
>  		if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
>  			gd->established = FALSE;
>  			authgss_destroy_context(auth);
> @@ -343,7 +343,7 @@ authgss_validate(AUTH *auth, struct opaque_auth *verf)
>  	gss_buffer_desc		 signbuf, checksum;
>  	OM_uint32		 maj_stat, min_stat;
>  
> -	log_debug("in authgss_validate()");
> +	gss_log_debug("in authgss_validate()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> @@ -379,7 +379,7 @@ authgss_validate(AUTH *auth, struct opaque_auth *verf)
>  	maj_stat = gss_verify_mic(&min_stat, gd->ctx, &signbuf,
>  				  &checksum, &qop_state);
>  	if (maj_stat != GSS_S_COMPLETE || qop_state != gd->sec.qop) {
> -		log_status("gss_verify_mic", maj_stat, min_stat);
> +		gss_log_status("gss_verify_mic", maj_stat, min_stat);
>  		if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
>  			gd->established = FALSE;
>  			authgss_destroy_context(auth);
> @@ -397,7 +397,7 @@ authgss_refresh(AUTH *auth)
>  	gss_buffer_desc		*recv_tokenp, send_token;
>  	OM_uint32		 maj_stat, min_stat, call_stat, ret_flags;
>  
> -	log_debug("in authgss_refresh()");
> +	gss_log_debug("in authgss_refresh()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> @@ -416,9 +416,9 @@ authgss_refresh(AUTH *auth)
>  #ifdef DEBUG
>  		/* print the token we just received */
>  		if (recv_tokenp != GSS_C_NO_BUFFER) {
> -			log_debug("The token we just received (length %d):",
> +			gss_log_debug("The token we just received (length %d):",
>  				  recv_tokenp->length);
> -			log_hexdump(recv_tokenp->value, recv_tokenp->length, 0);
> +			gss_log_hexdump(recv_tokenp->value, recv_tokenp->length, 0);
>  		}
>  #endif
>  		maj_stat = gss_init_sec_context(&min_stat,
> @@ -441,7 +441,7 @@ authgss_refresh(AUTH *auth)
>  		}
>  		if (maj_stat != GSS_S_COMPLETE &&
>  		    maj_stat != GSS_S_CONTINUE_NEEDED) {
> -			log_status("gss_init_sec_context", maj_stat, min_stat);
> +			gss_log_status("gss_init_sec_context", maj_stat, min_stat);
>  			break;
>  		}
>  		if (send_token.length != 0) {
> @@ -449,9 +449,9 @@ authgss_refresh(AUTH *auth)
>  
>  #ifdef DEBUG
>  			/* print the token we are about to send */
> -			log_debug("The token being sent (length %d):",
> +			gss_log_debug("The token being sent (length %d):",
>  				  send_token.length);
> -			log_hexdump(send_token.value, send_token.length, 0);
> +			gss_log_hexdump(send_token.value, send_token.length, 0);
>  #endif
>  
>  			call_stat = clnt_call(gd->clnt, NULLPROC,
> @@ -500,7 +500,7 @@ authgss_refresh(AUTH *auth)
>  
>  			if (maj_stat != GSS_S_COMPLETE
>  					|| qop_state != gd->sec.qop) {
> -				log_status("gss_verify_mic", maj_stat, min_stat);
> +				gss_log_status("gss_verify_mic", maj_stat, min_stat);
>  				if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
>  					gd->established = FALSE;
>  					authgss_destroy_context(auth);
> @@ -533,7 +533,7 @@ authgss_service(AUTH *auth, int svc)
>  {
>  	struct rpc_gss_data	*gd;
>  
> -	log_debug("in authgss_service()");
> +	gss_log_debug("in authgss_service()");
>  
>  	if (!auth)
>  		return(FALSE);
> @@ -551,7 +551,7 @@ authgss_destroy_context(AUTH *auth)
>  	struct rpc_gss_data	*gd;
>  	OM_uint32		 min_stat;
>  
> -	log_debug("in authgss_destroy_context()");
> +	gss_log_debug("in authgss_destroy_context()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> @@ -595,7 +595,7 @@ authgss_destroy(AUTH *auth)
>  	struct rpc_gss_data	*gd;
>  	OM_uint32		 min_stat;
>  
> -	log_debug("in authgss_destroy()");
> +	gss_log_debug("in authgss_destroy()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> @@ -616,7 +616,7 @@ authgss_wrap(AUTH *auth, XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr)
>  {
>  	struct rpc_gss_data	*gd;
>  
> -	log_debug("in authgss_wrap()");
> +	gss_log_debug("in authgss_wrap()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> @@ -633,7 +633,7 @@ authgss_unwrap(AUTH *auth, XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr)
>  {
>  	struct rpc_gss_data	*gd;
>  
> -	log_debug("in authgss_unwrap()");
> +	gss_log_debug("in authgss_unwrap()");
>  
>  	gd = AUTH_PRIVATE(auth);
>  
> diff --git a/src/authgss_prot.c b/src/authgss_prot.c
> index 0168318..a3c93c9 100644
> --- a/src/authgss_prot.c
> +++ b/src/authgss_prot.c
> @@ -64,10 +64,10 @@ xdr_rpc_gss_buf(XDR *xdrs, gss_buffer_t buf, u_int maxsize)
>  	if (xdr_stat && xdrs->x_op == XDR_DECODE)
>  		buf->length = tmplen;
>  
> -	log_debug("xdr_rpc_gss_buf: %s %s (%p:%d)",
> -		  (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> -		  (xdr_stat == TRUE) ? "success" : "failure",
> -		  buf->value, buf->length);
> +	gss_log_debug("xdr_rpc_gss_buf: %s %s (%p:%d)",
> +		      (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> +		      (xdr_stat == TRUE) ? "success" : "failure",
> +		      buf->value, buf->length);
>  
>  	return xdr_stat;
>  }
> @@ -83,12 +83,12 @@ xdr_rpc_gss_cred(XDR *xdrs, struct rpc_gss_cred *p)
>  		    xdr_enum(xdrs, (enum_t *)&p->gc_svc) &&
>  		    xdr_rpc_gss_buf(xdrs, &p->gc_ctx, MAX_AUTH_BYTES));
>  
> -	log_debug("xdr_rpc_gss_cred: %s %s "
> -		  "(v %d, proc %d, seq %d, svc %d, ctx %p:%d)",
> -		  (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> -		  (xdr_stat == TRUE) ? "success" : "failure",
> -		  p->gc_v, p->gc_proc, p->gc_seq, p->gc_svc,
> -		  p->gc_ctx.value, p->gc_ctx.length);
> +	gss_log_debug("xdr_rpc_gss_cred: %s %s "
> +		      "(v %d, proc %d, seq %d, svc %d, ctx %p:%d)",
> +		      (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> +		      (xdr_stat == TRUE) ? "success" : "failure",
> +		      p->gc_v, p->gc_proc, p->gc_seq, p->gc_svc,
> +		      p->gc_ctx.value, p->gc_ctx.length);
>  
>  	return (xdr_stat);
>  }
> @@ -101,10 +101,10 @@ xdr_rpc_gss_init_args(XDR *xdrs, gss_buffer_desc *p)
>  
>  	xdr_stat = xdr_rpc_gss_buf(xdrs, p, maxlen);
>  
> -	log_debug("xdr_rpc_gss_init_args: %s %s (token %p:%d)",
> -		  (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> -		  (xdr_stat == TRUE) ? "success" : "failure",
> -		  p->value, p->length);
> +	gss_log_debug("xdr_rpc_gss_init_args: %s %s (token %p:%d)",
> +		      (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> +		      (xdr_stat == TRUE) ? "success" : "failure",
> +		      p->value, p->length);
>  
>  	return (xdr_stat);
>  }
> @@ -123,13 +123,13 @@ xdr_rpc_gss_init_res(XDR *xdrs, struct rpc_gss_init_res *p)
>  		    xdr_u_int(xdrs, &p->gr_win) &&
>  		    xdr_rpc_gss_buf(xdrs, &p->gr_token, tok_maxlen));
>  
> -	log_debug("xdr_rpc_gss_init_res %s %s "
> -		  "(ctx %p:%d, maj %d, min %d, win %d, token %p:%d)",
> -		  (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> -		  (xdr_stat == TRUE) ? "success" : "failure",
> -		  p->gr_ctx.value, p->gr_ctx.length,
> -		  p->gr_major, p->gr_minor, p->gr_win,
> -		  p->gr_token.value, p->gr_token.length);
> +	gss_log_debug("xdr_rpc_gss_init_res %s %s "
> +		      "(ctx %p:%d, maj %d, min %d, win %d, token %p:%d)",
> +		      (xdrs->x_op == XDR_ENCODE) ? "encode" : "decode",
> +		      (xdr_stat == TRUE) ? "success" : "failure",
> +		      p->gr_ctx.value, p->gr_ctx.length,
> +		      p->gr_major, p->gr_minor, p->gr_win,
> +		      p->gr_token.value, p->gr_token.length);
>  
>  	return (xdr_stat);
>  }
> @@ -175,7 +175,7 @@ xdr_rpc_gss_wrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  		maj_stat = gss_get_mic(&min_stat, ctx, qop,
>  				       &databuf, &wrapbuf);
>  		if (maj_stat != GSS_S_COMPLETE) {
> -			log_debug("gss_get_mic failed");
> +			gss_log_debug("gss_get_mic failed");
>  			return (FALSE);
>  		}
>  		/* Marshal checksum. */
> @@ -189,7 +189,7 @@ xdr_rpc_gss_wrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  		maj_stat = gss_wrap(&min_stat, ctx, TRUE, qop, &databuf,
>  				    &conf_state, &wrapbuf);
>  		if (maj_stat != GSS_S_COMPLETE) {
> -			log_status("gss_wrap", maj_stat, min_stat);
> +			gss_log_status("gss_wrap", maj_stat, min_stat);
>  			return (FALSE);
>  		}
>  		/* Marshal databody_priv. */
> @@ -222,13 +222,13 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  	if (svc == RPCSEC_GSS_SVC_INTEGRITY) {
>  		/* Decode databody_integ. */
>  		if (!xdr_rpc_gss_buf(xdrs, &databuf, (u_int)-1)) {
> -			log_debug("xdr decode databody_integ failed");
> +			gss_log_debug("xdr decode databody_integ failed");
>  			return (FALSE);
>  		}
>  		/* Decode checksum. */
>  		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
>  			gss_release_buffer(&min_stat, &databuf);
> -			log_debug("xdr decode checksum failed");
> +			gss_log_debug("xdr decode checksum failed");
>  			return (FALSE);
>  		}
>  		/* Verify checksum and QOP. */
> @@ -238,14 +238,14 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  
>  		if (maj_stat != GSS_S_COMPLETE || qop_state != qop) {
>  			gss_release_buffer(&min_stat, &databuf);
> -			log_status("gss_verify_mic", maj_stat, min_stat);
> +			gss_log_status("gss_verify_mic", maj_stat, min_stat);
>  			return (FALSE);
>  		}
>  	}
>  	else if (svc == RPCSEC_GSS_SVC_PRIVACY) {
>  		/* Decode databody_priv. */
>  		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
> -			log_debug("xdr decode databody_priv failed");
> +			gss_log_debug("xdr decode databody_priv failed");
>  			return (FALSE);
>  		}
>  		/* Decrypt databody. */
> @@ -258,7 +258,7 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  		if (maj_stat != GSS_S_COMPLETE || qop_state != qop ||
>  			conf_state != TRUE) {
>  			gss_release_buffer(&min_stat, &databuf);
> -			log_status("gss_unwrap", maj_stat, min_stat);
> +			gss_log_status("gss_unwrap", maj_stat, min_stat);
>  			return (FALSE);
>  		}
>  	}
> @@ -271,7 +271,7 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  
>  	/* Verify sequence number. */
>  	if (xdr_stat == TRUE && seq_num != seq) {
> -		log_debug("wrong sequence number in databody");
> +		gss_log_debug("wrong sequence number in databody");
>  		return (FALSE);
>  	}
>  	return (xdr_stat);
> @@ -300,7 +300,7 @@ xdr_rpc_gss_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>  #include <ctype.h>
>  
>  void
> -log_debug(const char *fmt, ...)
> +gss_log_debug(const char *fmt, ...)
>  {
>  	va_list ap;
>  
> @@ -312,7 +312,7 @@ log_debug(const char *fmt, ...)
>  }
>  
>  void
> -log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
> +gss_log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
>  {
>  	OM_uint32 min;
>  	gss_buffer_desc msg;
> @@ -332,7 +332,7 @@ log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
>  }
>  
>  void
> -log_hexdump(const u_char *buf, int len, int offset)
> +gss_log_hexdump(const u_char *buf, int len, int offset)
>  {
>  	u_int i, j, jm;
>  	int c;
> @@ -367,17 +367,17 @@ log_hexdump(const u_char *buf, int len, int offset)
>  #else
>  
>  void
> -log_debug(const char *fmt, ...)
> +gss_log_debug(const char *fmt, ...)
>  {
>  }
>  
>  void
> -log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
> +gss_log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
>  {
>  }
>  
>  void
> -log_hexdump(const u_char *buf, int len, int offset)
> +gss_log_hexdump(const u_char *buf, int len, int offset)
>  {
>  }
>  
> diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
> index 54b23b1..9c74313 100644
> --- a/src/svc_auth_gss.c
> +++ b/src/svc_auth_gss.c
> @@ -87,13 +87,13 @@ svcauth_gss_set_svc_name(gss_name_t name)
>  {
>  	OM_uint32	maj_stat, min_stat;
>  
> -	log_debug("in svcauth_gss_set_svc_name()");
> +	gss_log_debug("in svcauth_gss_set_svc_name()");
>  
>  	if (_svcauth_gss_name != NULL) {
>  		maj_stat = gss_release_name(&min_stat, &_svcauth_gss_name);
>  
>  		if (maj_stat != GSS_S_COMPLETE) {
> -			log_status("gss_release_name", maj_stat, min_stat);
> +			gss_log_status("gss_release_name", maj_stat, min_stat);
>  			return (FALSE);
>  		}
>  		_svcauth_gss_name = NULL;
> @@ -101,7 +101,7 @@ svcauth_gss_set_svc_name(gss_name_t name)
>  	maj_stat = gss_duplicate_name(&min_stat, name, &_svcauth_gss_name);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_duplicate_name", maj_stat, min_stat);
> +		gss_log_status("gss_duplicate_name", maj_stat, min_stat);
>  		return (FALSE);
>  	}
>  
> @@ -115,7 +115,7 @@ svcauth_gss_import_name(char *service)
>  	gss_buffer_desc	namebuf;
>  	OM_uint32	maj_stat, min_stat;
>  
> -	log_debug("in svcauth_gss_import_name()");
> +	gss_log_debug("in svcauth_gss_import_name()");
>  
>  	namebuf.value = service;
>  	namebuf.length = strlen(service);
> @@ -124,7 +124,7 @@ svcauth_gss_import_name(char *service)
>  				   (gss_OID)GSS_C_NT_HOSTBASED_SERVICE, &name);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_import_name", maj_stat, min_stat);
> +		gss_log_status("gss_import_name", maj_stat, min_stat);
>  		return (FALSE);
>  	}
>  	if (svcauth_gss_set_svc_name(name) != TRUE) {
> @@ -139,14 +139,14 @@ svcauth_gss_acquire_cred(void)
>  {
>  	OM_uint32	maj_stat, min_stat;
>  
> -	log_debug("in svcauth_gss_acquire_cred()");
> +	gss_log_debug("in svcauth_gss_acquire_cred()");
>  
>  	maj_stat = gss_acquire_cred(&min_stat, _svcauth_gss_name, 0,
>  				    GSS_C_NULL_OID_SET, GSS_C_ACCEPT,
>  				    &_svcauth_gss_creds, NULL, NULL);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_acquire_cred", maj_stat, min_stat);
> +		gss_log_status("gss_acquire_cred", maj_stat, min_stat);
>  		return (FALSE);
>  	}
>  	return (TRUE);
> @@ -157,12 +157,12 @@ svcauth_gss_release_cred(void)
>  {
>  	OM_uint32	maj_stat, min_stat;
>  
> -	log_debug("in svcauth_gss_release_cred()");
> +	gss_log_debug("in svcauth_gss_release_cred()");
>  
>  	maj_stat = gss_release_cred(&min_stat, &_svcauth_gss_creds);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_release_cred", maj_stat, min_stat);
> +		gss_log_status("gss_release_cred", maj_stat, min_stat);
>  		return (FALSE);
>  	}
>  
> @@ -181,7 +181,7 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
>  	gss_OID			 mech;
>  	OM_uint32		 maj_stat = 0, min_stat = 0, ret_flags, seq;
>  
> -	log_debug("in svcauth_gss_accept_context()");
> +	gss_log_debug("in svcauth_gss_accept_context()");
>  
>  	gd = SVCAUTH_PRIVATE(rqst->rq_xprt->xp_auth);
>  	gc = (struct rpc_gss_cred *)rqst->rq_clntcred;
> @@ -208,7 +208,7 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
>  
>  	if (gr->gr_major != GSS_S_COMPLETE &&
>  	    gr->gr_major != GSS_S_CONTINUE_NEEDED) {
> -		log_status("accept_sec_context", gr->gr_major, gr->gr_minor);
> +		gss_log_status("accept_sec_context", gr->gr_major, gr->gr_minor);
>  		gd->ctx = GSS_C_NO_CONTEXT;
>  		gss_release_buffer(&min_stat, &gr->gr_token);
>  		return (FALSE);
> @@ -238,7 +238,7 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
>  		maj_stat = gss_display_name(&min_stat, gd->client_name,
>  					    &gd->cname, &gd->sec.mech);
>  		if (maj_stat != GSS_S_COMPLETE) {
> -			log_status("display_name", maj_stat, min_stat);
> +			gss_log_status("display_name", maj_stat, min_stat);
>  			return (FALSE);
>  		}
>  #ifdef DEBUG
> @@ -248,19 +248,19 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
>  
>  			gss_oid_to_str(&min_stat, mech, &mechname);
>  
> -			log_debug("accepted context for %.*s with "
> -				  "<mech %.*s, qop %d, svc %d>",
> -				  gd->cname.length, (char *)gd->cname.value,
> -				  mechname.length, (char *)mechname.value,
> -				  gd->sec.qop, gd->sec.svc);
> +			gss_log_debug("accepted context for %.*s with "
> +				      "<mech %.*s, qop %d, svc %d>",
> +				      gd->cname.length, (char *)gd->cname.value,
> +				      mechname.length, (char *)mechname.value,
> +				      gd->sec.qop, gd->sec.svc);
>  
>  			gss_release_buffer(&min_stat, &mechname);
>  		}
>  #elif HAVE_HEIMDAL
> -		log_debug("accepted context for %.*s with "
> -			  "<mech {}, qop %d, svc %d>",
> -			  gd->cname.length, (char *)gd->cname.value,
> -			  gd->sec.qop, gd->sec.svc);
> +		gss_log_debug("accepted context for %.*s with "
> +			      "<mech {}, qop %d, svc %d>",
> +			      gd->cname.length, (char *)gd->cname.value,
> +			      gd->sec.qop, gd->sec.svc);
>  #endif
>  #endif /* DEBUG */
>  		seq = htonl(gr->gr_win);
> @@ -289,7 +289,7 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
>  	u_char			 rpchdr[128];
>  	int32_t			*buf;
>  
> -	log_debug("in svcauth_gss_validate()");
> +	gss_log_debug("in svcauth_gss_validate()");
>  
>  	memset(rpchdr, 0, sizeof(rpchdr));
>  
> @@ -326,7 +326,7 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
>  				  &qop_state);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_verify_mic", maj_stat, min_stat);
> +		gss_log_status("gss_verify_mic", maj_stat, min_stat);
>  		return (FALSE);
>  	}
>  	return (TRUE);
> @@ -339,7 +339,7 @@ svcauth_gss_nextverf(struct svc_req *rqst, u_int num)
>  	gss_buffer_desc		 signbuf, checksum;
>  	OM_uint32		 maj_stat, min_stat;
>  
> -	log_debug("in svcauth_gss_nextverf()");
> +	gss_log_debug("in svcauth_gss_nextverf()");
>  
>  	if (rqst->rq_xprt->xp_auth == NULL)
>  		return (FALSE);
> @@ -353,7 +353,7 @@ svcauth_gss_nextverf(struct svc_req *rqst, u_int num)
>  			       &signbuf, &checksum);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		log_status("gss_get_mic", maj_stat, min_stat);
> +		gss_log_status("gss_get_mic", maj_stat, min_stat);
>  		return (FALSE);
>  	}
>  	rqst->rq_xprt->xp_verf.oa_flavor = RPCSEC_GSS;
> @@ -373,7 +373,7 @@ _svcauth_gss(struct svc_req *rqst, struct rpc_msg *msg, bool_t *no_dispatch)
>  	struct rpc_gss_init_res	 gr;
>  	int			 call_stat, offset;
>  
> -	log_debug("in svcauth_gss()");
> +	gss_log_debug("in svcauth_gss()");
>  
>  	/* Initialize reply. */
>  	rqst->rq_xprt->xp_verf = _null_auth;
> @@ -519,7 +519,7 @@ svcauth_gss_destroy(SVCAUTH *auth)
>  	struct svc_rpc_gss_data	*gd;
>  	OM_uint32		 min_stat;
>  
> -	log_debug("in svcauth_gss_destroy()");
> +	gss_log_debug("in svcauth_gss_destroy()");
>  
>  	gd = SVCAUTH_PRIVATE(auth);
>  
> @@ -540,7 +540,7 @@ svcauth_gss_wrap(SVCAUTH *auth, XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr)
>  {
>  	struct svc_rpc_gss_data	*gd;
>  
> -	log_debug("in svcauth_gss_wrap()");
> +	gss_log_debug("in svcauth_gss_wrap()");
>  
>  	gd = SVCAUTH_PRIVATE(auth);
>  
> @@ -557,7 +557,7 @@ svcauth_gss_unwrap(SVCAUTH *auth, XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr
>  {
>  	struct svc_rpc_gss_data	*gd;
>  
> -	log_debug("in svcauth_gss_unwrap()");
> +	gss_log_debug("in svcauth_gss_unwrap()");
>  
>  	gd = SVCAUTH_PRIVATE(auth);
>  
> diff --git a/tirpc/rpc/auth_gss.h b/tirpc/rpc/auth_gss.h
> index 633b11f..fc3ffbd 100644
> --- a/tirpc/rpc/auth_gss.h
> +++ b/tirpc/rpc/auth_gss.h
> @@ -120,10 +120,10 @@ bool_t authgss_service		__P((AUTH *auth, int svc));
>  bool_t authgss_get_private_data	__P((AUTH *auth,
>  	    			     struct authgss_private_data *));
>  
> -void	log_debug		__P((const char *fmt, ...));
> -void	log_status		__P((char *m, OM_uint32 major,
> +void	gss_log_debug		__P((const char *fmt, ...));
> +void	gss_log_status		__P((char *m, OM_uint32 major,
>  				     OM_uint32 minor));
> -void	log_hexdump		__P((const u_char *buf, int len, int offset));
> +void	gss_log_hexdump		__P((const u_char *buf, int len, int offset));
>  
>  __END_DECLS
>  
Committed..

steved

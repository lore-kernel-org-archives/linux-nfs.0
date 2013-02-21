Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982Ab3BUT6N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 14:58:13 -0500
Date: Thu, 21 Feb 2013 14:58:10 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "simo@redhat.com" <simo@redhat.com>
Subject: Re: [PATCH 5/6] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20130221195810.GD3531@pad.fieldses.org>
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
> > From: Simo Sorce <simo@redhat.com>
> > 
> > This patch implements a sunrpc client to use the services of the gssproxy
> > userspace daemon.
> > 
> > In particular it allows to perform calls in user space using an RPC
> > call instead of custom hand-coded upcall/downcall messages.
> > 
> > Currently only accept_sec_context is implemented as that is all is needed for
> > the server case.
> > 
> > File server modules like NFS and CIFS can use full gssapi services this way,
> > once init_sec_context is also implemented.
> > 
> > For the NFS server case this code allow to lift the limit of max 2k krb5
> > tickets. This limit is prevents legitimate kerberos deployments from using krb5
> > authentication with the Linux NFS server as they have normally ticket that are
> > many kilobytes large.
> > 
> > It will also allow to lift the limitation on the size of the credential set
> > (uid,gid,gids) passed down from user space for users that have very many groups
> > associated. Currently the downcall mechanism used by rpc.svcgssd is limited
> > to around 2k secondary groups of the 65k allowed by kernel structures.
> > 
> > Signed-off-by: Simo Sorce <simo@redhat.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/Makefile         |    3 +-
> >  net/sunrpc/auth_gss/gss_rpc_upcall.c |  353 +++++++++++++
> >  net/sunrpc/auth_gss/gss_rpc_upcall.h |   43 ++
> >  net/sunrpc/auth_gss/gss_rpc_xdr.c    |  906 ++++++++++++++++++++++++++++++++++
> >  net/sunrpc/auth_gss/gss_rpc_xdr.h    |  269 ++++++++++
> >  5 files changed, 1573 insertions(+), 1 deletion(-)
> >  create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.c
> >  create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.h
> >  create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.c
> >  create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.h
> > 
> > diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
> > index 9e4cb59..14e9e53 100644
> > --- a/net/sunrpc/auth_gss/Makefile
> > +++ b/net/sunrpc/auth_gss/Makefile
> > @@ -5,7 +5,8 @@
> >  obj-$(CONFIG_SUNRPC_GSS) += auth_rpcgss.o
> >  
> >  auth_rpcgss-y := auth_gss.o gss_generic_token.o \
> > -	gss_mech_switch.o svcauth_gss.o
> > +	gss_mech_switch.o svcauth_gss.o \
> > +	gss_rpc_upcall.o gss_rpc_xdr.o
> >  
> >  obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> > new file mode 100644
> > index 0000000..5fd8c91
> > --- /dev/null
> > +++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> > @@ -0,0 +1,353 @@
> > +/*
> > + *  linux/net/sunrpc/gss_rpc_upcall.c
> > + *
> > + *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation; either version 2 of the License, or
> > + * (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + * You should have received a copy of the GNU General Public License
> > + * along with this program; if not, write to the Free Software
> > + * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> > + */
> > +
> > +#include <linux/types.h>
> > +#include <linux/un.h>
> > +
> > +#include <linux/sunrpc/svcauth.h>
> > +#include "gss_rpc_upcall.h"
> > +
> > +#define GSSPROXY_SOCK_PATHNAME	"/var/run/gssproxy.sock"
> > +
> > +#define GSSPROXY_PROGRAM	(400112u)
> > +#define GSSPROXY_VERS_1		(1u)
> > +
> > +DEFINE_MUTEX(gssp_clnt_mutex);
> > +struct rpc_clnt *gssp_clnt;
> > +
> > +/*
> > + * Encoding/Decoding functions
> > + */
> > +
> > +enum {
> > +	GSSX_NULL = 0,	/* Unused */
> > +        GSSX_INDICATE_MECHS = 1,
> > +        GSSX_GET_CALL_CONTEXT = 2,
> > +        GSSX_IMPORT_AND_CANON_NAME = 3,
> > +        GSSX_EXPORT_CRED = 4,
> > +        GSSX_IMPORT_CRED = 5,
> > +        GSSX_ACQUIRE_CRED = 6,
> > +        GSSX_STORE_CRED = 7,
> > +        GSSX_INIT_SEC_CONTEXT = 8,
> > +        GSSX_ACCEPT_SEC_CONTEXT = 9,
> > +        GSSX_RELEASE_HANDLE = 10,
> > +        GSSX_GET_MIC = 11,
> > +        GSSX_VERIFY = 12,
> > +        GSSX_WRAP = 13,
> > +        GSSX_UNWRAP = 14,
> > +        GSSX_WRAP_SIZE_LIMIT = 15,
> > +};
> > +
> > +#define PROC(proc, name)				\
> > +[GSSX_##proc] = {					\
> > +	.p_proc   = GSSX_##proc,			\
> > +	.p_encode = (kxdreproc_t)gssx_enc_##name,	\
> > +	.p_decode = (kxdrdproc_t)gssx_dec_##name,	\
> > +	.p_arglen = GSSX_ARG_##name##_sz,		\
> > +	.p_replen = GSSX_RES_##name##_sz, 		\
> > +	.p_statidx = GSSX_##proc,			\
> > +	.p_name   = #proc,				\
> > +}
> > +
> > +struct rpc_procinfo gssp_procedures[] = {
> > +	PROC(INDICATE_MECHS, indicate_mechs),
> > +        PROC(GET_CALL_CONTEXT, get_call_context),
> > +        PROC(IMPORT_AND_CANON_NAME, import_and_canon_name),
> > +        PROC(EXPORT_CRED, export_cred),
> > +        PROC(IMPORT_CRED, import_cred),
> > +        PROC(ACQUIRE_CRED, acquire_cred),
> > +        PROC(STORE_CRED, store_cred),
> > +        PROC(INIT_SEC_CONTEXT, init_sec_context),
> > +        PROC(ACCEPT_SEC_CONTEXT, accept_sec_context),
> > +        PROC(RELEASE_HANDLE, release_handle),
> > +        PROC(GET_MIC, get_mic),
> > +        PROC(VERIFY, verify),
> > +        PROC(WRAP, wrap),
> > +        PROC(UNWRAP, unwrap),
> > +        PROC(WRAP_SIZE_LIMIT, wrap_size_limit),
> > +};
> > +
> > +
> > +
> > +/*
> > + * Common transport functions
> > + */
> > +
> > +static const struct rpc_program gssp_program;
> > +
> > +static int gssp_rpc_create(struct net *net, struct rpc_clnt **_clnt)
> > +{
> > +	static const struct sockaddr_un gssp_localaddr = {
> > +		.sun_family		= AF_LOCAL,
> > +		.sun_path		= GSSPROXY_SOCK_PATHNAME,
> > +	};
> > +	struct rpc_create_args args = {
> > +		.net		= net,
> > +		.protocol	= XPRT_TRANSPORT_LOCAL,
> > +		.address	= (struct sockaddr *)&gssp_localaddr,
> > +		.addrsize	= sizeof(gssp_localaddr),
> > +		.servername	= "localhost",
> > +		.program	= &gssp_program,
> > +		.version	= GSSPROXY_VERS_1,
> > +		.authflavor	= RPC_AUTH_NULL,
> > +		.flags		= RPC_CLNT_CREATE_NOPING,
> > +	};
> > +	struct rpc_clnt *clnt;
> > +	int result = 0;
> > +
> > +	clnt = rpc_create(&args);
> > +	if (IS_ERR(clnt)) {
> > +		dprintk("RPC:       failed to create AF_LOCAL gssproxy "
> > +				"client (errno %ld).\n", PTR_ERR(clnt));
> > +		result = -PTR_ERR(clnt);
> > +		*_clnt = NULL;
> > +		goto out;
> > +	}
> > +
> > +	dprintk("RPC:       created new gssp local client (gssp_local_clnt: "
> > +			"%p)\n", clnt);
> > +	*_clnt = clnt;
> > +
> > +out:
> > +	return result;
> > +}
> > +
> > +static struct rpc_clnt *get_clnt(struct net *net, bool global_clnt)
> > +{
> > +	struct rpc_clnt *clnt;
> > +	int err;
> > +
> > +	mutex_lock(&gssp_clnt_mutex);
> > +
> > +	if (global_clnt && gssp_clnt)
> > +		return gssp_clnt;
> 
> Ehem.... mutex_unlock()? Better yet, add an 'out:' label below, and
> replace all the 'return' statements with gotos...

Ugh, sorry, this was a patch-ordering problem, I fixed this then merged
the fix into a later patch instead of this one.

I'll fix that and work through your following comments, thanks!

--b.

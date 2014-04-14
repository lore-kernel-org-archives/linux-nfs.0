Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbaDNSgi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2014 14:36:38 -0400
Subject: Re: [PATCH 5/5] gssd: scrape the acceptor name out of the context
From: Simo Sorce <simo@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
In-Reply-To: <20140414114851.40dcbcfe@ipyr.poochiereds.net>
References: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
	 <1397161863-29266-6-git-send-email-jlayton@redhat.com>
	 <534BF9B9.3000707@RedHat.com>
	 <20140414114851.40dcbcfe@ipyr.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Apr 2014 14:36:34 -0400
Message-ID: <1397500594.19767.258.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-04-14 at 11:48 -0400, Jeff Layton wrote:
> On Mon, 14 Apr 2014 11:07:37 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
> > Hey Jeff,
> > 
> > Just a couple nit.... 
> > 
> > On 04/10/2014 04:31 PM, Jeff Layton wrote:
> > > ...and pass it to the kernel in the downcall. Legacy kernels will just
> > > ignore the extra data, but with a proposed kernel patch the kernel will
> > > grab this info and use it to verify requests on the v4.0 callback
> > > channel.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  utils/gssd/gssd_proc.c | 39 ++++++++++++++++++++++++++++-----------
> > >  1 file changed, 28 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > index 7387cce010cf..d95e39416c28 100644
> > > --- a/utils/gssd/gssd_proc.c
> > > +++ b/utils/gssd/gssd_proc.c
> > > @@ -77,6 +77,7 @@
> > >  #include "context.h"
> > >  #include "nfsrpc.h"
> > >  #include "nfslib.h"
> > > +#include "gss_names.h"
> > >  
> > >  /*
> > >   * pollarray:
> > > @@ -683,16 +684,19 @@ parse_enctypes(char *enctypes)
> > >  
> > >  static void
> > >  do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
> > > -	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec)
> > > +	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec,
> > > +	    gss_buffer_desc *acceptor)
> > >  {
> > >  	char    *buf = NULL, *p = NULL, *end = NULL;
> > >  	unsigned int timeout = context_timeout;
> > >  	unsigned int buf_size = 0;
> > >  
> > > -	printerr(1, "doing downcall lifetime_rec %u\n", lifetime_rec);
> > > +	printerr(1, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
> > > +		lifetime_rec, acceptor->length, acceptor->value);
> > >  	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
> > >  		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
> > > -		sizeof(context_token->length) + context_token->length;
> > > +		sizeof(context_token->length) + context_token->length +
> > > +		acceptor->length;
> > >  	p = buf = malloc(buf_size);
> > >  	if (!buf)
> > >  		goto out_err;
> > > @@ -707,6 +711,8 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
> > >  	if (WRITE_BYTES(&p, end, pd->pd_seq_win)) goto out_err;
> > >  	if (write_buffer(&p, end, &pd->pd_ctx_hndl)) goto out_err;
> > >  	if (write_buffer(&p, end, context_token)) goto out_err;
> > > +	if (acceptor->length > 0 &&
> > > +	    write_buffer(&p, end, acceptor)) goto out_err;
> > >  
> > >  	if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
> > >  	free(buf);
> > > @@ -1034,6 +1040,9 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
> > >  	gss_cred_id_t		gss_cred;
> > >  	OM_uint32		maj_stat, min_stat, lifetime_rec;
> > >  	pid_t			pid;
> > > +	gss_name_t		gacceptor;
> > > +	gss_OID			mech;
> > > +	gss_buffer_desc		acceptor  = {0};
> > >  
> > >  	pid = fork();
> > >  	switch(pid) {
> > > @@ -1174,15 +1183,22 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
> > >  		goto out_return_error;
> > >  	}
> > >  
> > > -	/* Grab the context lifetime to pass to the kernel. lifetime_rec
> > > -	 * is set to zero on error */
> > Why get rid of this comment instead of updating it? 
> > 
> 
> I suppose I could do that. Would you prefer I respin and update that
> comment instead?
> 
> > > -	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, NULL,
> > > -				       &lifetime_rec, NULL, NULL, NULL, NULL);
> > > +	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, &gacceptor,
> > > +				       &lifetime_rec, &mech, NULL, NULL, NULL);
> > >  
> > > -	if (maj_stat)
> > > -		printerr(1, "WARNING: Failed to inquire context for lifetme "
> > > -			    "maj_stat %u\n", maj_stat);
> > > +	if (maj_stat != GSS_S_COMPLETE) {
> > > +		printerr(1, "WARNING: Failed to inquire context "
> > > +			    "maj_stat (0x%x)\n", maj_stat);
> > > +	} else {
> > > +		get_hostbased_client_buffer(gacceptor, mech, &acceptor);
> > > +		gss_release_name(&min_stat, &gacceptor);
> > > +	}
> > >  
> > > +	/*
> > > +	 * The serialization can mean turning the ctx into a lucid context. If
> > > +	 * that happens then the original ctx is no longer valid, so we mustn't
> > > +	 * try to use if after this point.
> > I'm not sure what you are trying to say here... 
> > 
> > steved.
> > 
> 
> Just a semi-helpful context for posterity...
> 
> On my initial attempt, I tried to change the code around to grab the
> lifetime and acceptor out of the context in do_downcall. That didn't
> work, because once you call serialize_context_for_kernel, the GSS
> context is turned into a "lucid context". At that point, things like
> gss_inquire_context no longer work on it.
> 
> IOW, once you call serialize_context_for_kernel, you can't count on
> being able to do anything useful with pd.pd_ctx at all.

This is on purpose, when you export the lucid context, the original
context is destroyed, this is to avoid having 2 parties with a context
for the same connection as the sequence numbers would get messed up and
communication fail if 2 parties tried to use them at the same time
anyway.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York


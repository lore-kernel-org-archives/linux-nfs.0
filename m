Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257Ab3JEWCY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Oct 2013 18:02:24 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r95M2Nxd027674
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 5 Oct 2013 18:02:23 -0400
Date: Sat, 5 Oct 2013 18:04:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Simo Sorce <ssorce@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] gssd: switch real uid instead of just fsuid when
 looking for user creds
Message-ID: <20131005180403.12301e80@corrin.poochiereds.net>
In-Reply-To: <1937105088.1804058.1380916002471.JavaMail.root@redhat.com>
References: <1380829760-4928-1-git-send-email-jlayton@redhat.com>
	<1380829760-4928-3-git-send-email-jlayton@redhat.com>
	<1937105088.1804058.1380916002471.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 4 Oct 2013 15:46:42 -0400 (EDT)
Simo Sorce <ssorce@redhat.com> wrote:

> 
> 
> ----- Original Message -----
> > The part of process_krb5_upcall that handles non-machine user creds
> > first tries to query GSSAPI for credentials. If that fails, it then
> > falls back to trawling through likely credcache locations to find them
> > and then points $KRB5CCNAME at it before proceeding. There are a number
> > of bugs in this code that this patch attempts to address.
> > 
> > The code that queries GSSAPI for credentials does it as root and that
> > almost universally fails to do anything useful unless we happen to be
> > looking for non-machine root creds. Because of this, gssd almost always
> > falls back to having to search for credcaches "manually" and then set
> > $KRB5CCNAME if and when they are found. The code that handles credential
> > switching is in create_auth_rpc_client, so it's too late to be of any
> > use here.
> > 
> > Worse yet, the GSSAPI code that handles finding credcaches does it based
> > on the return from getuid(), so just switching the fsuid or even euid is
> > insufficient. You must switch the real uid.
> 
> In what case does it do this ?
> If it is unconditional this is a bug in GSSAPI and we should fix it there.
> 

As far as I can tell (primarily from stracing and experimenting) it
always does this. Additionally it looks like KEYRING: support might
also depend on this.

> You shouldn't really change the real uid of gssd because then the user can
> send a kill to the gssd process, only euid should be changed IMO.
> 

Perhaps you missed the first patch in the series that makes gssd fork()
before doing this? That prevents the main daemon from being affected.
Only the forked thread handling the upcall should be vulnerable. That's
unfortunate, but seems like a reasonable way to deal with the needs of
GSSAPI.

> > This code moves the credential switching into process_krb5_upcall and
> > makes it use setuid() instead of setfsuid(). That's of course
> > irreversible so we can't switch back to root after doing so. No matter
> > though since it's probably safer to do all of this as an unprivileged
> > user anyway.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  utils/gssd/gssd_proc.c | 26 ++++++++++----------------
> >  1 file changed, 10 insertions(+), 16 deletions(-)
> > 
> > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > index fd258f7..4856d08 100644
> > --- a/utils/gssd/gssd_proc.c
> > +++ b/utils/gssd/gssd_proc.c
> > @@ -834,7 +834,6 @@ create_auth_rpc_client(struct clnt_info *clp,
> >  	CLIENT			*rpc_clnt = NULL;
> >  	struct rpc_gss_sec	sec;
> >  	AUTH			*auth = NULL;
> > -	uid_t			save_uid = -1;
> >  	int			retval = -1;
> >  	OM_uint32		min_stat;
> >  	char			rpc_errmsg[1024];
> > @@ -843,16 +842,6 @@ create_auth_rpc_client(struct clnt_info *clp,
> >  	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
> >  	socklen_t		salen;
> >  
> > -	/* Create the context as the user (not as root) */
> > -	save_uid = geteuid();
> > -	if (setfsuid(uid) != 0) {
> > -		printerr(0, "WARNING: Failed to setfsuid for "
> > -			    "user with uid %d\n", uid);
> > -		goto out_fail;
> > -	}
> > -	printerr(2, "creating context using fsuid %d (save_uid %d)\n",
> > -			uid, save_uid);
> > -
> >  	sec.qop = GSS_C_QOP_DEFAULT;
> >  	sec.svc = RPCSEC_GSS_SVC_NONE;
> >  	sec.cred = cred;
> > @@ -951,11 +940,6 @@ create_auth_rpc_client(struct clnt_info *clp,
> >    out:
> >  	if (sec.cred != GSS_C_NO_CREDENTIAL)
> >  		gss_release_cred(&min_stat, &sec.cred);
> > -	/* Restore euid to original value */
> > -	if (((int)save_uid != -1) && (setfsuid(save_uid) != (int)uid)) {
> > -		printerr(0, "WARNING: Failed to restore fsuid"
> > -			    " to uid %d from %d\n", save_uid, uid);
> > -	}
> >  	return retval;
> >  
> >    out_fail:
> > @@ -1033,6 +1017,16 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid,
> > int fd, char *tgtname,
> >  		 service ? service : "<null>");
> >  	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
> >  				service == NULL)) {
> > +
> > +		/* Create the context as the user (not as root) */
> > +		if (setuid(uid) != 0) {
> > +			printerr(0, "WARNING: Failed to setuid for "
> > +					"user with uid %d\n", uid);
> > +			goto out_return_error;
> > +		}
> > +
> > +		printerr(2, "creating context using real uid %d\n", uid);
> > +
> >  		/* Tell krb5 gss which credentials cache to use */
> >  		/* Try first to acquire credentials directly via GSSAPI */
> >  		err = gssd_acquire_user_cred(uid, &gss_cred);
> > --
> > 1.8.3.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 


-- 
Jeff Layton <jlayton@redhat.com>

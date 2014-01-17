Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbaAQB22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jan 2014 20:28:28 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0H1SSc6027725
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 20:28:28 -0500
Subject: Re: [PATCH] Fix crdential sourcing with new setuid behavior in
 rpc.gssd
From: Simo Sorce <simo@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <20140116104707.6b4c11fe@tlielax.poochiereds.net>
References: <1389822094.26102.488.camel@willson.li.ssimo.org>
	 <20140116104707.6b4c11fe@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jan 2014 20:28:27 -0500
Message-ID: <1389922107.2370.13.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-01-16 at 10:47 -0500, Jeff Layton wrote:
> On Wed, 15 Jan 2014 16:41:34 -0500
> Simo Sorce <simo@redhat.com> wrote:
> 
> > From 421f66b1cd0b031ef843f7680f463027904b93ca Mon Sep 17 00:00:00 2001
> > From: Simo Sorce <simo@redhat.com>
> > Date: Wed, 15 Jan 2014 16:01:49 -0500
> > Subject: [PATCH] Improve first attempt at acquiring GSS credentials
> > 
> > Since now rpc.gssd is swithing uid before attempting to acquire
> > credentials, we do not need to pass in the special uid-as-a-string name
> > to gssapi, because the process is already running under the user's
> > credentials.
> > 
> > By making this optional we can fix a class of false negatives where the
> > user name does not match the actual ccache credentials and the ccache
> > type used is not one of the only 2 supported explicitly by rpc.gssd by the
> > fallback trolling done later.
> > 
> > Signed-off-by: Simo Sorce <simo@redhat.com>
> > ---
> >  utils/gssd/krb5_util.c | 32 ++++++++++++++++++--------------
> >  1 file changed, 18 insertions(+), 14 deletions(-)
> > 
> > diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> > index 697d1d2e79db0cc38160ea4772d3af3a9b7d6c21..7db5baf4e4bea75ed7beebd2103afbc291efb641 100644
> > --- a/utils/gssd/krb5_util.c
> > +++ b/utils/gssd/krb5_util.c
> > @@ -1383,24 +1383,28 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
> >  {
> >  	OM_uint32 maj_stat, min_stat;
> >  	gss_buffer_desc name_buf;
> > -	gss_name_t name;
> > +	gss_name_t name = GSS_C_NO_NAME;
> >  	char buf[11];
> >  	int ret;
> >  
> > -	ret = snprintf(buf, 11, "%u", uid);
> > -	if (ret < 1 || ret > 10) {
> > -		return -1;
> > -	}
> > -	name_buf.value = buf;
> > -	name_buf.length = ret + 1;
> > +	/* the follwing is useful only if change_identity() in
> > +	 * process_krb5_upcall() failed to change uids */
> > +	if (getuid() == 0) {
> > +		ret = snprintf(buf, 11, "%u", uid);
> > +		if (ret < 1 || ret > 10) {
> > +			return -1;
> > +		}
> > +		name_buf.value = buf;
> > +		name_buf.length = ret + 1;
> >  
> 
> If change_identity() fails, then process_krb5_upcall should just give
> up and do an error downcall, so falling back to using
> GSS_C_NT_STRING_UID_NAME in that case seems unnecessary.
> 
> Also, we can end up in here legitimately with uid == 0 if
> root_uses_machine_creds == 0. So I wonder if we even need the stuff
> inside this "if (getuid() == 0)" block at all...

I were under the impression that rpc.gssd could still be used without
doing the fork()/setuid() dance, and I didn't really check if it really
is conditional.

If it is not and the only case where uid = 0 is when rpc.gssd is
actually performing the operation on behalf of root, then yeah we can
simply remove everything in the if branch.

Let me know how you want to proceed. 

> Other than that, I'm fine with ripping that junk out.

Ok, so should I sent a patch that just removes, instead of making
conditional, this chunk of code ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York


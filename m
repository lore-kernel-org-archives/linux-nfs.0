Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab3HBRAf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 13:00:35 -0400
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for
 persistent per-UID kerberos caches
From: Simo Sorce <simo@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, krbdev@mit.edu,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <7136.1375462405@warthog.procyon.org.uk>
References: <20130802095555.07a2cda3@tlielax.poochiereds.net>
	 <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	 <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	 <7136.1375462405@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 02 Aug 2013 13:00:21 -0400
Message-ID: <1375462821.15733.262.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-08-02 at 17:53 +0100, David Howells wrote:
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > > +	/* -1 indicates the current user */
> > > +	if (_uid == (uid_t)-1) {
> > > +		uid = current_uid();
> >
> > Isn't it possible to have a valid uid of (unsigned int)-1? I know that
> > at least some sites use that for "nobody". Why not just require passing
> > in the correct UID?
> 
> See setresuid() and co. - there -1 is "don't change".
> 
> > Looks good overall, but I share Daniel's concerns about making
> > krb5-specific infrastructure like this. Essentially this is just a
> > persistent keyring that's associated with a kuid, right? Perhaps this
> > could be done in such a way that it could be usable for other
> > applications in the future?
> 
> It's not too hard, I suppose:
> 
> 	keyctl_get_persistent(uid, prefix, destring)
> 
> eg:
> 
> 	keyctl_get_persistent(-1, "_krb.", KEYCTL_SPEC_PROCESS_KEYRING)
> 
> giving:
> 
> 	struct user_namespace
> 	  \___ .krb_cache keyring
> 		\___ _krb.0 keyring
> 		\___ _krb.5000 keyring
> 		\___ _krb.5001 keyring
> 		|	\___ tkt785 big_key
> 		|	\___ tkt12345 big_key
> 		\___ _afs.5000 keyring
> 			\___ afs.redhat.com rxrpc
> 
> The other way to do it is create one keyring per user and let userspace create
> subkeyrings under that:
> 
> 	struct user_namespace
> 	  \___ .krb_cache keyring
> 		\___ _uid_p.0 keyring
> 		\___ _uid_p.5000 keyring
> 		\___ _uid_p.5001 keyring
> 			\___ krb keyring
> 			|	\___ tkt785 big_key
> 			|	\___ tkt12345 big_key
> 			\___ afs keyring
> 				\___ afs.redhat.com rxrpc
> 
> In the above scheme, it might be worth just making these the same as the user
> keyring - which means KEYCTL_SPEC_USER_KEYRING will automatically target it.
> 
> Simo:  I believe the problem you have with the user keyring is that it's not
> persistent beyond the life of the processes of that UID, right?

Correct.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York


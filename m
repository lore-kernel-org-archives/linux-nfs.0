Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27455 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab3HBRNt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 13:13:49 -0400
Date: Fri, 2 Aug 2013 13:13:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: simo@redhat.com, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for
 persistent per-UID kerberos caches
Message-ID: <20130802131344.19e14521@tlielax.poochiereds.net>
In-Reply-To: <7136.1375462405@warthog.procyon.org.uk>
References: <20130802095555.07a2cda3@tlielax.poochiereds.net>
	<20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	<20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	<7136.1375462405@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 02 Aug 2013 17:53:25 +0100
David Howells <dhowells@redhat.com> wrote:

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

<facepalm>

Good point. I got confused between -1 and -2. I think Solaris uses
(uid_t)-2 for nobody. Using -1 in this case should be fine.

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


That's probably what I'd suggest. Allow one persistent keyring per
user, and expect userland to organize things sanely under it.

nit: I probably wouldn't call the top-level keyring "krb_cache"
though ;)

> In the above scheme, it might be worth just making these the same as the user
> keyring - which means KEYCTL_SPEC_USER_KEYRING will automatically target it.
> 
> Simo:  I believe the problem you have with the user keyring is that it's not
> persistent beyond the life of the processes of that UID, right?
> 

Possibly. It really comes down to what sort of lifecycle you expect here.

Some applications might be caught by surprise if the per-user keyring
was already populated in certain situations. OTOH, they have the same
problem if there's even one running process with that uid so maybe it's
not a big deal.

If you do this, it might make sense to allow the admin to tune the
expiry sysctl in such a way that user keyrings go away as soon as
the last reference is gone (maybe by setting it to 0?).

-- 
Jeff Layton <jlayton@redhat.com>

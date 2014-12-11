Return-Path: jeff.layton@primarydata.com
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 11 Dec 2014 14:50:29 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, Ian Kent <ikent@redhat.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        David Howells
 <dhowells@redhat.com>,
        David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141211145029.4761b61e@tlielax.poochiereds.net>
In-Reply-To: <20141211193240.GO20526@fieldses.org>
References: <20141210065240.77a23160@tlielax.poochiereds.net>
	<33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
	<20141210091734.3c612514@tlielax.poochiereds.net>
	<cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
	<32108.1418227382@warthog.procyon.org.uk>
	<alpine.OSX.2.19.9992.1412101744200.92934@planck.local>
	<1418256763.2566.61.camel@pluto.fritz.box>
	<alpine.OSX.2.19.9992.1412102045190.92934@planck.local>
	<1418268081.2566.67.camel@pluto.fritz.box>
	<20141211064537.540e2e12@tlielax.poochiereds.net>
	<20141211193240.GO20526@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 11 Dec 2014 14:32:40 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Dec 11, 2014 at 06:45:37AM -0500, Jeff Layton wrote:
> > For instance: module loading clearly needs to be done in the "context"
> > of the canonical root init process. That's what call_usermodehelper was
> > originally used for so we need to keep that ability intact.
> > 
> > OTOH, keyring upcalls probably ought to be done in the context of the
> > task that triggered them. Certainly we ought to be spawning them with
> > the credentials associated with the keyring.
> 
> Isn't the idmapping done as a keyring upcall?  You don't want ordinary
> users of the filesystem to be able to pollute the id<->name cache.
> 

Yes, it is done as a keyring upcall. You wouldn't need to allow random
users to pollute the cache. When you do a keys upcall the process gets
an authorization key that allows it to instantiate the key.

AFAIU, that's what guards against random processes polluting the
keyring, not any particular capabilities or anything.

> And in the gssd case, userland doesn't just find the right cred, it also
> does the rpcsec_gss context setup with the server.  A random user of the
> filesystem might not be able to do that part.
> 

I don't see why not. We already do that today as an unprivileged user
in gssd. process_krb5_upcall forks and changes identity before getting
a ticket and setting up the context and then handing that back to the
kernel. I don't think that requires any special privileges.

-- 
Jeff Layton <jlayton@primarydata.com>

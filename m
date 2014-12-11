Return-Path: bfields@fieldses.org
Date: Thu, 11 Dec 2014 14:32:40 -0500
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Ian Kent <ikent@redhat.com>, Benjamin Coddington <bcodding@redhat.com>,
        David Howells <dhowells@redhat.com>,
        David =?utf-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141211193240.GO20526@fieldses.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141211064537.540e2e12@tlielax.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 11, 2014 at 06:45:37AM -0500, Jeff Layton wrote:
> For instance: module loading clearly needs to be done in the "context"
> of the canonical root init process. That's what call_usermodehelper was
> originally used for so we need to keep that ability intact.
> 
> OTOH, keyring upcalls probably ought to be done in the context of the
> task that triggered them. Certainly we ought to be spawning them with
> the credentials associated with the keyring.

Isn't the idmapping done as a keyring upcall?  You don't want ordinary
users of the filesystem to be able to pollute the id<->name cache.

And in the gssd case, userland doesn't just find the right cred, it also
does the rpcsec_gss context setup with the server.  A random user of the
filesystem might not be able to do that part.

--b.

> 
> Today, those tasks not only run in the namespaces, etc of the root init
> process, but also with with root's creds. That's unnecessary and seems
> wrong. I think it's something that ought to be changed (though doing so
> will likely be painful as we'll need to change the upcall programs to
> handle that).
> 
> There are also other questions:
> 
> How should we go about spawning the binary given that we might want to
> have it run in a different mount namespace? There are at least two
> options:
> 
> 1) change the mount namespace first and then exec the binary (in effect
> run the binary with the given path from inside the container). This is
> possibly a security hole if an attacker can trick the kernel into
> running a different binary than intended by manipulating namespaces.
> 
> ...or...
> 
> 2) find and exec the binary and then change the namespaces afterward.
> This has some potential problems if the program does something like
> try to dlopen libraries after setns(). You could end up with a mismatch
> if the container holds a different set of binaries from the one in the
> root container.
> 
> -- 
> Jeff Layton <jlayton@primarydata.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: ikent@redhat.com
Message-ID: <1418336419.2509.12.camel@pluto.fritz.box>
Subject: Re: [PATCH 00/19] gssd improvements
From: Ian Kent <ikent@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Benjamin Coddington
 <bcodding@redhat.com>,
        David Howells <dhowells@redhat.com>,
        David
 =?ISO-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com, idra@samba.org
Date: Fri, 12 Dec 2014 06:20:19 +0800
In-Reply-To: <20141211203841.GQ20526@fieldses.org>
References: <32108.1418227382@warthog.procyon.org.uk>
	 <alpine.OSX.2.19.9992.1412101744200.92934@planck.local>
	 <1418256763.2566.61.camel@pluto.fritz.box>
	 <alpine.OSX.2.19.9992.1412102045190.92934@planck.local>
	 <1418268081.2566.67.camel@pluto.fritz.box>
	 <20141211064537.540e2e12@tlielax.poochiereds.net>
	 <20141211193240.GO20526@fieldses.org>
	 <20141211145029.4761b61e@tlielax.poochiereds.net>
	 <20141211195527.GP20526@fieldses.org>
	 <20141211151135.6ba88835@tlielax.poochiereds.net>
	 <20141211203841.GQ20526@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-12-11 at 15:38 -0500, J. Bruce Fields wrote:
> On Thu, Dec 11, 2014 at 03:11:35PM -0500, Jeff Layton wrote:
> > On Thu, 11 Dec 2014 14:55:27 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Dec 11, 2014 at 02:50:29PM -0500, Jeff Layton wrote:
> > > > On Thu, 11 Dec 2014 14:32:40 -0500
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Thu, Dec 11, 2014 at 06:45:37AM -0500, Jeff Layton wrote:
> > > > > > For instance: module loading clearly needs to be done in the "context"
> > > > > > of the canonical root init process. That's what call_usermodehelper was
> > > > > > originally used for so we need to keep that ability intact.
> > > > > > 
> > > > > > OTOH, keyring upcalls probably ought to be done in the context of the
> > > > > > task that triggered them. Certainly we ought to be spawning them with
> > > > > > the credentials associated with the keyring.
> > > > > 
> > > > > Isn't the idmapping done as a keyring upcall?  You don't want ordinary
> > > > > users of the filesystem to be able to pollute the id<->name cache.
> > > > > 
> > > > 
> > > > Yes, it is done as a keyring upcall. You wouldn't need to allow random
> > > > users to pollute the cache. When you do a keys upcall the process gets
> > > > an authorization key that allows it to instantiate the key.
> > > > 
> > > > AFAIU, that's what guards against random processes polluting the
> > > > keyring, not any particular capabilities or anything.
> > > 
> > > That doesn't stop it from instantiating the key with the wrong
> > > information.
> > > 
> > 
> > I guess I'm unclear on the attack vector you're talking about. The
> > difference is the credentials that we give the process when its run by
> > call_usermodehelper. Why would it be inherently more secure for that to
> > be given root credentials rather than something non-privileged?
> > 
> > The only way you can add keys to a keyring you don't own is to have an
> > authorization key, and that would only be given to the process that got
> > spawned by the kernel.
> 
> OK.  I was interpreting "keyring upcalls probably out to be done in the
> context of the task that triggered them" to mean they should be done
> with all the various namespaces of that task, which would among other
> things give unprivileged users control over the mapping.

TBH I think it's too early to decide these issues.

So far I've been thinking the "struct cred", as in process credentials,
should be chosen by the caller. And I'm assuming that's sufficient
although it may not be.

The important thing is to first work out how to execute a binary within
container context in a way that satisfies the security requirements that
previous attempts didn't. Then step back and work out what we have to do
for the specific use cases while maintaining that requirement.
 
> 
> > > > > And in the gssd case, userland doesn't just find the right cred, it also
> > > > > does the rpcsec_gss context setup with the server.  A random user of the
> > > > > filesystem might not be able to do that part.
> > > > > 
> > > > 
> > > > I don't see why not. We already do that today as an unprivileged user
> > > > in gssd. process_krb5_upcall forks and changes identity before getting
> > > > a ticket and setting up the context and then handing that back to the
> > > > kernel. I don't think that requires any special privileges.
> > > 
> > > Why couldn't you give a task access to an nfs filesystem but wall it off
> > > in a network namespace where it doesn't even have access to the
> > > interface that the mount was done over?
> > > 
> > 
> > That's a pathological case. ;) I suppose you could do that, at which
> > point you'd be screwed. That's the unfortunate side of having all of
> > these disconnected types of namespaces. You can use these Lego bricks
> > to build something either awesome or completely non-functional. I don't
> > think we can really solve all possible use-cases since some of them are
> > non-sensical anyway. I think all we can do is target the use-cases that
> > we think make sense and take it from there.
> 
> I think it's pretty normal to sandbox tasks to deny them network access,
> and I wouldn't expect that to mean giving up access to mounted nfs
> filesystems.
> 
> > While we're on the subject, having the userland process establish the
> > GSS context over an entirely separate connection is a hack anyway. We
> > really ought to be doing that using the same connection. Simo had some
> > arguments against that scheme a while back, but I don't recall the
> > details -- seems like maybe it breaks channel bindings? While we're
> > talking about rejiggering all of this, that would be a good thing to
> > change as well.
> 
> It was Simo that wanted to move the context establishment into kernel
> sunrpc code and Trond that objected to that.  And yes one of the only
> practical differences we could come up with is that having it in the
> kernel and sharing the same connection would allow channel bindings.
> But nobody seems to care about channel bindings for now.
> 
> It's a long-running argument--the first gssd prototypes basically did
> gssapi over rpc (a little like gssproxy) and it was Trond that wanted
> the whole negotiation done in userspace.
> 
> --b.
> 
> > > (And similarly what's to guarantee that a user of the filesystem is
> > > capable of doing the ldap calls you might need for idmapping?)
> > > 
> > 
> > Yeah, that certainly could be a problem. I'm not sure we'd really want
> > to do the idmapping upcalls as the user that triggered them in the case
> > of the idmapper. Perhaps there ought to be a specific set of
> > credentials associated with the keyring that the idmapper uses instead?
> > Those don't necessarily need to be root creds of course.

Return-Path: ikent@redhat.com
Message-ID: <1418268081.2566.67.camel@pluto.fritz.box>
Subject: Re: [PATCH 00/19] gssd improvements
From: Ian Kent <ikent@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        Jeff Layton
	 <jeff.layton@primarydata.com>,
        David =?ISO-8859-1?Q?H=E4rdeman?=
	 <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Date: Thu, 11 Dec 2014 11:21:21 +0800
In-Reply-To: <alpine.OSX.2.19.9992.1412102045190.92934@planck.local>
References: <20141210093405.23ffc328@tlielax.poochiereds.net>
	  <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
	  <20141209080923.2708eb4f@tlielax.poochiereds.net>
	  <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
	  <20141209095813.163ac2bb@tlielax.poochiereds.net>
	 <20141209195530.GA27798@hardeman.nu>
	  <20141210065240.77a23160@tlielax.poochiereds.net>
	  <33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
	  <20141210091734.3c612514@tlielax.poochiereds.net>
	  <cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
	  <32108.1418227382@warthog.procyon.org.uk>
	  <alpine.OSX.2.19.9992.1412101744200.92934@planck.local>
	 <1418256763.2566.61.camel@pluto.fritz.box>
	 <alpine.OSX.2.19.9992.1412102045190.92934@planck.local>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-12-10 at 20:54 -0500, Benjamin Coddington wrote:
> 
> On Thu, 11 Dec 2014, Ian Kent wrote:
> 
> > On Wed, 2014-12-10 at 18:21 -0500, Benjamin Coddington wrote:
> > > On Wed, 10 Dec 2014, David Howells wrote:
> > >
> > > > Jeff Layton <jeff.layton@primarydata.com> wrote:
> > > >
> > > > > > This thread might be interesting:
> > > > > > https://lkml.org/lkml/2014/11/24/885
> > > > > >
> > > > >
> > > > > Nice. I wasn't aware that Ian was working on this. I'll take a look.
> > > >
> > > > I'm not sure what the current state of this is.  There was some discussion
> > > > over how best to determine which container we need to run in - and it's
> > > > complicated by the fact that the mounter may run in a different container to
> > > > the program that triggered the mount due to mountpoint propagation.
> > > >
> > > > David
> > >
> > > The specific problem of how to run /sbin/request-key in the caller's
> > > "container" for idmap and gssd (and other friends) became more generally a
> > > problem of how to solve the namespace (or more generally again, "context")
> > > problem for some users of kmod's call_usermodehelper.  The nice thing about
> > > call_usermodehelper is that you don't have to do a lot of work to set up a
> > > process to get something done in userspace -- however it is sounding more
> > > like we do need to work hard to set up context for some users.
> > >
> > > The userspace work needs to be done within a context that currently exists
> > > or once existed, so the questions are where do we get that context and how
> > > do we keep it around until we need it?
> > >
> > > I think there's agreement that the setup of that context should be basically
> > > what's done in fork() for consistency and future work.  So we get LSM and
> > > cgroups, etc.. in addition to namespaces.
> >
> > And that's when the usermode helper init function is called, just before
> > the exec, so I think that's the place it needs to be done.
> >
> > >
> > > There are two suggested approaches:
> > >
> > > 1) Anytime we think we're going to later need to upcall with a context we
> > > fork and keep a thread around to do that work.  For NFS, that would look
> > > like forking a thread for every mount at mount time.  The user of this API
> > > would be responsible for creating/maintaining the thread and passing it
> > > along for work.
> >
> > Yeah, I don't think that's workable for large numbers of mounts and I
> > don't think it's really necessary.
> >
> > >
> > > 2) Specify that a usermodehelper should attempt to use a context rather than
> > > the default root context.  The context used would be taken from the "init"
> > > process of the current pid_namespace.  Either that init_process itself could
> > > be asked to fork/execve or when the pid_namespace is created a separate
> > > helper thread is reserved.
> >
> > I think this is doable using open()/setns() in a similar way to
> > nsenter(1). We can worry about simplifying it once we have a viable
> > approach to work from.
> >
> > The reality is that now user mode helpers are executed within the root
> > context of init so I can't see why we can't use the context of init of
> > the container for this.
> >
> > Modifying that along the way with a "struct cred" is probably a good
> > idea although it isn't done now for user mode callbacks. The "struct
> > cred" of the root init process surely isn't what needs to be used when
> > executing in a container so something needs to be done. If we duplicate
> > the same behaviour we have now for execution outside of a container then
> > we'd use the "struct cred" of the container init process so maybe we do
> > know where to get the cred, not sure about that though.
> 
> I'm not following you entirely here.  Do you mean that the helper should
> probably have the container init's cred stripped off or sanitized?

LOL, that's good question.

What I think I'm saying is that, when the usermode helper is run we
don't want to use root init's credentials but some other credentials
relevant to the container, possibly the credentials of the mounter or
nfsd process credentials or the container init credentials.

In any case they will need to be set to something different and
appropriate. I'm not sure how to do that just yet.

Ian

Return-Path: ikent@redhat.com
Message-ID: <1418255073.2566.43.camel@pluto.fritz.box>
Subject: Re: [PATCH 00/19] gssd improvements
From: Ian Kent <ikent@redhat.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: David Howells <dhowells@redhat.com>, bcodding@redhat.com,
        David
	=?ISO-8859-1?Q?H=E4rdeman?=
	 <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Date: Thu, 11 Dec 2014 07:44:33 +0800
In-Reply-To: <20141210140311.7fb7b159@tlielax.poochiereds.net>
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
	 <20141210140311.7fb7b159@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-12-10 at 14:03 -0500, Jeff Layton wrote:
> On Wed, 10 Dec 2014 16:03:02 +0000
> David Howells <dhowells@redhat.com> wrote:
> 
> > Jeff Layton <jeff.layton@primarydata.com> wrote:
> > 
> > > > This thread might be interesting:
> > > > https://lkml.org/lkml/2014/11/24/885
> > > > 
> > > 
> > > Nice. I wasn't aware that Ian was working on this. I'll take a look.
> > 
> > I'm not sure what the current state of this is.  There was some discussion
> > over how best to determine which container we need to run in - and it's
> > complicated by the fact that the mounter may run in a different container to
> > the program that triggered the mount due to mountpoint propagation.
> > 
> 
> Yes. It's quite a thorny problem.

And I'm still not sure how to work that out ....

> 
> Part of the issue is that the different namespaces (net, mount, etc...)
> are completely orthogonal to one another as far as the kernel is
> concerned, but they really can't be when we start talking about
> userland stuff.

Yeah, and the way that open()/setns() works is strange.

The open() gets you access to the proc_ns_operations (umm .. from
memory) used by setns() to install one of the created namespaces into
the process nsproxy but the namespace create always creates all six (or
seven) namespaces and releases them all on subsequent open()/setns()
operations to install a another namespace.

Sure, I don't properly understand this yet but it seems a bit odd.

> 
> For example, all of the nfs and nfsd namespace code was tied to the net
> namespace. But, once you start involving things like gssd, the mount
> namespace matters too as it has to deal with files (libraries and
> config files, in particular).
> 
> Q: What happens if you have two "containers" that have the same net
> namespace but different mount namespaces along with a different krb5
> configuration in each? Maybe even with a gssd running in each?

I'm assuming that, to execute a helper within a container, the
namespaces of the container itself should always be used.
 
If we follow the open()/setns() procedure in kernel, similar to
nsenter(1) that should be possible.

Yes, it does seem more complex than it needs to be, due to what I
described above, but we need a starting point.

At the moment I'm struggling to work out where to get an appropriate
"struct cred" and how to override this in the new process.

> 
> A: A horrible mess, AFAICT...
> 
> Without something that really enforces a 1:1 relationship between all
> of the different sorts of namespaces, the whole container/namespace
> concept quickly descends into a horrid mess. It makes my head hurt.
> 

Mine too, ;)

Ian

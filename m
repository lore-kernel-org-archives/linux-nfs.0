From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol (XATTR)
Date: Mon, 15 Mar 2010 03:19:51 +0000
Message-ID: <20100315031951.GU6491@shareable.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org> <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org> <20100309035932.GA14237@cynthia.pants.nu> <4B95E167.40306@schaufler-ca.com> <20100309070444.GA18216@cynthia.pants.nu> <20100309193545.GE11042@shareable.org> <4B971611.8030801@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brad Boyer <flar@allandria.com>, James Morris <jmorris@namei.org>,
	linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B971611.8030801@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Casey Schaufler wrote:
> Jamie Lokier wrote:
> > Brad Boyer wrote:
> >   
> >> On Mon, Mar 08, 2010 at 09:49:27PM -0800, Casey Schaufler wrote:
> >>     
> >>> Another is to NFS mount the filesystem back on to the server,
> >>> in which case James' scheme works just dandy. It's a trick that
> >>> I've used more than once in the Unix world for this exact purpose.
> >>> Of course you have to arrange your mount points in advance with
> >>> malice aforethought, but that's likely something you're used to
> >>> by now.
> >>>       
> >> That would definitely work, but it's not ideal. Obviously if it's
> >> being accessed over NFS in one place it probably good enough
> >> everywhere, but it's overhead that could be eliminated.
> >>     
> >
> > As a real example:
> >
> > Each user has a PC with their own home directory being local, fast
> > storage, but /home is filled with NFS auto-mounts to everyone else's
> > home directories, on their individual PCs.  The auto-mount map has an
> > exception, so the local user's home directory is a symlink to the
> > local storage, instead of an NFS mount.
> >
> > A scheme like that works very well for occasional access to other
> > peoples files, and for logging to each other's machines transparently,
> > yet having fast performance for their own files when using their local
> > machine.
> >
> > In an environment where I've used that, forcing local access to go
> > over local NFS would have destroyed performance for things like big
> > compiles, running find, git, grep etc. that people do on their own
> > directories.
> >
> >   
> 
> Sure. The original objection can be readily addressed. There are
> performance implications. Just like you'd have if the home directories
> resided on a storage appliance. Some people pick security for the
> masses over performance for the few. Some the other way round.
> It's not an issue for people who want labeled NFS3 badly enough
> to install it.

It seems in this case, the performance implications are totally unnecassary.

Why not a mount option for the xattr name translation?

-- Jamie

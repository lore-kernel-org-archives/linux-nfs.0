From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: intent patches
Date: Mon, 26 May 2003 00:31:46 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <16081.17490.889937.791357@charged.uio.no>
References: <20030525074243.GF18405@localhost.localdomain>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@parcelfarce.linux.theplanet.co.uk,
	Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>,
	lustre-devel@lists.sf.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Peter Braam <braam@clusterfs.com>
In-Reply-To: <20030525074243.GF18405@localhost.localdomain>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Peter Braam <braam@clusterfs.com> writes:

     > We _do_ have resources to sort it all out very agressively in
     > the next few weeks.

Good. Let's do that...

     > We currently use intents for two methods:
     > - getattr
     > - open
     > For other methods, we would like the intents also, but they did
     > not solve all our woes.  We may have overlooked one or two,
     > like permission.

Permission provides a pretty major source of optimization as far as
NFS is concerned: we can ignore it for all operations *except* open(),
and cached lookup().

     > We introduced lookup2 and d_revalidate2 to avoid changing all
     > file systems and in 2.5 we give them a namei data parameter.

Is this really desirable? It makes maintenance easy when you are
making add-on patches for the kernel, but IMHO it otherwise just makes
for a confusing interface.

     > We would like to pass a pointer to nameidata to:

     > - open (file method)
     > - create directory (inode method)
     > - lookup (inode method)
     > - revalidate (dentry method)

All those are good as far as I'm concerned.

     > - revalidate (inode method)

That's no longer in 2.5.x. Do you perhaps mean the new getattr()?

     > and perhaps also to mkdir, rmdir, unlink, rename, mknod,
     > setattr.

setattr() may help for NFSv4 where we can do open(O_TRUNC) atomically
on the server, and could optimize away the truncation.

The other ops aren't really prime candidates for optimization,
although we could possibly plonk the lookup+op into a single RPC call
by means of the COMPOUND call (again NFSv4 only).

     >   We have not done so yet, and can work aroud this by adding a
     >   field
     >      struct lookup_intent *d_it
     > in a dentry. This is not elegant, and the protection of this
     > field is delicate, but avoids large scale api changes.

Hmmm...

     > Trond changes all callers instead of adding lookup2 (better
     > long term, very invasive for pre-2.6)

We could mitigate the effects by making the nameidata field an
optional one. Of course, that would make it harder to add support for
credentials.

     > he has vfsintent point to nameidata and inside "opendata" and
     > we have the exact opposite...

Swapping will fail to offend any deeply held religious beliefs of
mine. No problems there...

     > We do all methods.

Yep. As you can see I've looked only at those methods that are known
to have the largest impact w.r.t. the NFS client.

Cheers,
  Trond

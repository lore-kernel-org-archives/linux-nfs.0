From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: (unknown)
Date: Fri,  8 Jun 2007 18:14:50 -0400
Message-ID: <6186.87889441407$1181340912@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Robert Rappaport <robert.rappaport@gmail.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Subject: 
In-Reply-To: <20070607170557.GA14463@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


J. Bruce Fields <bfields@fieldses.org> wrote:
> OK, good.  I'll revise and post a new series.  (Do people prefer
> another mailbomb or a git url?)

OK, I went for the former; if you'd rather get this out of git, you can

	git clone http://www.linux-nfs.org/~bfields/linux.git
	git checkout server-cluster-lease-api

The changes from the last version seem pretty trivial, but I've
compile-tested this only for now.

I'm ignoring the problem of breaking leases on unlink and rename.  I
think we should go ahead and do this part now--it's adequate for the
current lease semantics, and even more so for our current application
(just turning off leases selectively on some filesystems)--but I'd
really like to solve that problem eventually.

That's probably not going to happen until we get a cluster filesystem
with real lease support into the kernel....

Changes:
	- do away with the break_lease method.
	- rename __setlease to setlease, setlease to vfs_setlease, and
	  make sure it's setlease (the one that doesn't call into the
	  filesystem) that's exported.
	- rename ->set_lease to ->setlease.  (I don't really care which
	  we go with, it just seemed confusing when everything else was
	  already named without the underscore.)
	- Add a trivial patch that disables leases on nfs (as suggested
	  by a patch elsewhere from Peter Staubach)

--b.

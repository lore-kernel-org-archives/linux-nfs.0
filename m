From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: NFS server development update
Date: Thu, 27 Sep 2007 11:32:33 -0400
Message-ID: <20070927153233.GE2522@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

These days Neil Brown and I are maintaining the NFS server together, and
I'm currently (as of the last few weeks) tracking the to-be-submitted
patches.

I have limited time and am not expert on all of the relevant code, so I
depend on your help!  I'm still experimenting a bit with the process
(suggestions welcomed), but most of the following should be obvious to
anyone who's been working on the kernel for a while.

I keep all the pending NFS and sunrpc server patches that I believe are
done in the "nfs-server-stable" branch here[1]:

	git://linux-nfs.org/~bfields/linux.git nfs-server-stable

I also include nfs-server-stable in the "for-mm" branch, which is
normally included in Andrew's -mm kernels automatically, and which may
sometimes also contain other works-in-progress.

I'll try to submit urgent[2] patches to upstream immediately.  All the
other patches in nfs-server-stable will be submitted in one batch just
after each new kernel release (that's about once every two months).

If you want patches included, email them to me, one patch per message,
in the format described in[3]

	http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt

and also cc: nfs@lists.sourceforge.net, Neil Brown <neilb@suse.de>, and
anyone you consider particularly qualified to review your work.  Also,
please state clearly that you're asking me to apply your patches;
otherwise I may just assume you're asking people for early feedback on
work in progress (which is also encouraged, of course).  If you get no
response and your work doesn't show up in my git tree, I may have
forgotten; please remind me.  If I ignore something urgent, please try
Neil, Andrew, lkml, and/or Linus as necessary.

If you're fixing a mistake in a patch I already have, I'd usually prefer
an incremental patch as opposed to a complete replacement.

If you have large changes you'd like included in the next kernel, try to
submit them well in advance of the release of the current kernel.  (For
example, with 2.6.23 about to be released, it may already be too late
for major changes to be included in 2.6.24.)

I'll follow up with a summary of the patches I currently have.

--b.

Notes:

[1] My suggestion for how to access my git tree:
	1. Install git version 1.5.0 or later
	2. If you haven't already, get Linus's tree with:
		git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
		cd linux-2.6.git
	3. Tell git about my tree with:
		git remote add bfields git://linux-nfs.org/~bfields/linux.git
		git fetch bfields
	4. View current server patches with:
		gitk origin..bfields/nfs-server-stable
	4. Update as necessary using:
		git fetch bfields

[2] A patch will be more likely to be treated as "urgent" if it is
obviously correct and if it fixes a severe problem (for example, one
that corrupts data or compromises security).  As a release approaches,
and the time remaining to test new patches decreases, the standard for
such patches will become harder to meet.

[3] If you're new to the process, the contents of

	http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt

and Documentation/SubmittingPatches are useful, but possibly also
overwhelming.  The important points are:

	- Each patch should make one set of logically related changes
	  and come with a comment that explains what the patch does and
	  why.
	- No patch should introduce a regression: after applying the
	  first n patches of a series (for any n), the kernel should
	  still compile and run.  It's not OK to introduce a bug in
	  one patch and then fix it in some later patch; instead, you
	  need to figure out how to reorder your changes.

Our goal is to improve the kernel through a long series of small,
incremental, easy to understand, and individually testable changes.

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Fri, 8 Dec 2006 12:35:54 -0500
Message-ID: <20061208173554.GA20240@fieldses.org>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu> <20061206154951.GB16378@redhat.com> <20061206195722.GH1714@fieldses.org> <20061206205822.GB25322@redhat.com> <20061206212347.GA25465@fieldses.org> <20061206214231.GC25322@redhat.com> <20061206220029.GC25465@fieldses.org> <20061207153043.GB14548@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: David Teigland <teigland@redhat.com>
In-Reply-To: <20061207153043.GB14548@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Dec 07, 2006 at 09:30:43AM -0600, David Teigland wrote:
> Some posix locks would be trivial to cancel and others would be hard.  If
> gfs_controld has not yet read the op from the kernel's send_list, then we
> just remove the op and it never "goes out".  After gfs_controld has taken
> it and sent it, then it's had its effect and, as you reminded me, is
> unreversible without introducing new complexity (like the provisional
> locks which sound unpleasant).

Something like that may be necessary in the end anyway.  The background:

NFSv4 doesn't have lock grant callbacks.  It only has a single lock
call.  You can set a "blocking" bit in that call, but all this does is
tell the server "I intend continue polling for this lock, so if it
becomes available, could you hold it a little while to give me a chance
at it before anyone else?"  That's just a hint, not a requirement.  But
if we don't take the hint, locking between clients with different
polling strategies, or between remote clients and local users, may be
dramatically unfair.

The client also isn't required to poll for the lock again--it may stop
without notice at any time.  So we'd like to have a way to hold a lock
on behalf of a client, without losing the ability to cancel the lock if
the client goes away.  Hence the provisional locks.

For now, maybe we could settle for a solution that at least handles
exclusive whole-file locking (for which an unlock is an adequate
cancel), and leaves open the possibility of a more complete solution
later.

--b.

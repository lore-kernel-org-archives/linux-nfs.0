From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] dlm: initialize file_lock struct in GETLK before
 copying conflicting lock
Date: Tue, 27 Jan 2009 18:30:45 -0500
Message-ID: <20090127183045.58582d21@tleilax.poochiereds.net>
References: <1232651764-10799-1-git-send-email-jlayton@redhat.com>
	<1232651764-10799-2-git-send-email-jlayton@redhat.com>
	<20090127223401.GL9151@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, cluster-devel@redhat.com,
	teigland@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090127223401.GL9151@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 Jan 2009 17:34:01 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jan 22, 2009 at 02:16:03PM -0500, Jeff Layton wrote:
> > dlm_posix_get fills out the relevant fields in the file_lock before
> > returning when there is a lock conflict, but doesn't clean out any of
> > the other fields in the file_lock.
> > 
> > When nfsd does a NFSv4 lockt call, it sets the fl_lmops to
> > nfsd_posix_mng_ops before calling the lower fs. When the lock comes back
> > after testing a lock on GFS2, it still has that field set. This confuses
> > nfsd into thinking that the file_lock is a nfsd4 lock.
> > 
> > Fix this by making DLM reinitialize the file_lock before copying the
> > fields from the conflicting lock.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> I'll leave this one to gfs2 people to apply unless I'm told otherwise.
> 
> --b.
> 

That should be fine. Dave T. has taken this into his tree and is
pushing it to Linus.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

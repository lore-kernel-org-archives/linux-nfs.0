From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.29, holidays
Date: Mon, 2 Feb 2009 17:58:05 -0500
Message-ID: <20090202225805.GE13389@fieldses.org>
References: <20081222171124.GL4191@fieldses.org> <494FD604.6020502@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <494FD604.6020502@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 22, 2008 at 08:01:40PM +0200, Benny Halevy wrote:
> On Dec. 22, 2008, 19:11 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > I'm leaving town till the new year.  It's likely 2.6.28 will be released
> > (and the 2.6.29 merge window open) on Christmas, though the merge window
> > will be extended to take into account the holidays:
> > 
> > 	http://lwn.net/Articles/312154/
> > 
> > I'll be online at least part of the time, and review outstanding patches
> > from Chuck and Benny (and hopefully Steved's export patches).  If you
> > have other server stuff pending for 2.6.29, please remind me.
> 
> Hi Bruce,
> 
> First, enjoy your vacation!
> Regarding 2.6.29, how about the following patch from Alexandros?
> http://git.linux-nfs.org/?p=bhalevy/linux-pnfs.git;a=commitdiff;h=35bbe2824b991e14877e7ceb6a36f91e2ea78226
> I haven't sent it to you for 2.6.29 but I believe it's a good opportunity
> to get it in.

Thanks, a little late, but I've applied that....

I also spent some time trying to figure out what to do about the nfs4
server's locking.  The scope of the state lock is a problem, mainly
because (at least for me) it's hard to understand what it's protecting
at this point.  And of course I worry about performance: I haven't tried
to measure lock contention, but it can't be good that the same lock that
can be held over disk access (read/write code isn't under it, but lots
of lookups and creates are) is also used for simple hash-table lookups.

I got as far as looking at nfsd4_open() and despaired.

A global spinlock or two for the various hash tables, together with a
semaphore for each stateowner, to serialize the stateid replay stuff,
might do the job.

Anyway, I committed some very minor cleanup of the open code--you can
see it at for-2.6.30, if anyone's interested, but didn't get any
further.

--b.

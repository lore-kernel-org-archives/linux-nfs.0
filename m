From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Tue, 8 Jun 2004 13:05:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16581.11543.342424.795946@cse.unsw.edu.au>
References: <20040506185603.GM23287@polop.usc.edu>
	<20040506191351.GP23287@polop.usc.edu>
	<20040506215311.GA26968@polop.usc.edu>
	<20040506222455.GP18964@fieldses.org>
	<20040506230055.GC26968@polop.usc.edu>
	<20040507182543.GA27341@fieldses.org>
	<20040507213811.GL30964@polop.usc.edu>
	<20040507223414.GQ30964@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXWwI-0007px-TZ
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 20:06:14 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXWwI-0003SN-82
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 20:06:14 -0700
To: Garrick Staples <garrick@usc.edu>
Cc: nfs@lists.sourceforge.net
In-Reply-To: message from Garrick Staples on Friday May 7
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday May 7, garrick@usc.edu wrote:
> On Fri, May 07, 2004 at 02:38:12PM -0700, Garrick Staples alleged:
> > But now I've just noticed something else that is odd.  Something that I'm
> > surprised I haven't come across before...  I have to unexport filesystems
> > twice before I can unmount them.

Thanks for reporting this.  Sorry it has taken me so long to look at
it.

I can reproduce the problem, and I know what is causing it.

When caches are flushed, as they are at export, unexport, or
re-export, the caches are flushed in the order:
  auth.unix.ip   nfsd.export nfsd.fh

Flushing a cache involves:

  1/ setting the "flush_time" on a cache to the time given.  This has
    the effect of marking all entries in the cache with an earlier
    update time as expired.
  2/ setting the "nextcheck" time for the cache to "now" so that all
    entries will be checked when we....
  2/ call  "cache_flush", which checks which entries have expired, and
    are no longer in use, and remove them.

The problem is that entries in nfsd.fh refer to entries in
nfsd.export.  So when we flush nfsd.export, some entries will still
be in-use by nfsd.fh and so will not be removed.

We then flush nfsd.fh, which calls "cache_flush", but as the nextcheck
on nfsd.export has been updated, it isn't checked again.  So the entry
stays there.

The fix, which I have tested and does appear to work, is to change the
order in which the caches are flushed.  This is in "cache_flush" at
the end of support/nfs/cache.io.c  The order should be:
	static char *cachelist[] = {
		"auth.unix.ip",
		"nfsd.fh",
		"nfsd.export",
		NULL
	};


> 
> I'm looking at exportfs.c to see if I can add in a call to flush the caching
> when unmounting, does the following seem reasonable?

The code already flushes the caches if anything has changed.

Towards the end of main() in exportfs.c there is:

	xtab_export_write();
	if (new_cache)
		cache_flush(force_flush);

xtab_export_write writes out a new copy of the export table and if
that is different (byte for byte) from the old copy, it is moved
in place of the old copy.  So if you didn't make a change, the file
isn't touched.

Then cache_flush will flush the caches giving the modify time on the
'etab' file (which xtab_export_write might have changed) as the flush
time.  If "force_flush==1", the current time is used instead of the
modify time.

So exportfs will always flush the caches, but will only flush entries
added before the etab file was last updated.

Adding "-f" will make it flush all changes, even if the etab isn't
updated.

So I cannot see how your patch would make any difference.  Setting
force_flush at that point would have zero effect if the exportfs
command actually changed the etab file at all.

Your change to remove rmtab_read when new_cache is probably good,
though I cannot see how it would have a significant effect in this
case.

And to answer Bruce's subsequent question:
> Can someone explaing what the reason was for adding the -f flag to
> exportfs?
Because it is useful for testing.  It should not be needed during
normal running.

I'll check-in the cache-flush-order and the no-rmtab_read changes to
CVS shortly.

NeilBrown




> 
> Force a cache flush if unexporting, and don't reread rmtab if we're using the
> new cache.
> 
> --- exportfs.c_orig     2004-05-07 15:32:22.423905760 -0700
> +++ exportfs.c  2004-05-07 15:33:33.669998637 -0700
> @@ -127,10 +127,13 @@
>                  */
>                 if (!f_reexport)
>                         xtab_export_read();
> -               if (!f_export)
> +               if (!f_export) {
> +                       force_flush=1;
>                         for (i = optind ; i < argc ; i++)
>                                 unexportfs(argv[i], f_verbose);
> -               rmtab_read();
> +               }
> +               if (!new_cache)
> +                       rmtab_read();
>         }
>         if (!new_cache) {
>                 xtab_mount_read();
> 
> 
> -- 
> Garrick Staples, Linux/HPCC Administrator
> University of Southern California


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:60630 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab3FEDlR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jun 2013 23:41:17 -0400
Date: Wed, 5 Jun 2013 04:41:15 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [patch/rfc] allow exported (and *not* exported) filesystems to
 be unmounted.
Message-ID: <20130605034115.GD13110@ZenIV.linux.org.uk>
References: <20130605130541.5968d5c2@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130605130541.5968d5c2@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 05, 2013 at 01:05:41PM +1000, NeilBrown wrote:
> 
> Hi Bruce,
>  this is a little issue that seems to keep coming up so I thought it might be
>  time to fix it.
> 
>  As you know, a filesystem that is exported cannot be unmounted as the export
>  cache holds a reference to it.  Though if it hasn't been accessed for a
>  while then it can.
> 
>  As I hadn't realised before sometimes *non* exported filesystems can be
>  pinned to.  A negative entry in the cache can pin a filesystem just as
>  easily as a positive entry.
>  An amusing, if somewhat contrived, example is that if you export '/' with
>  crossmnt and:
> 
>     mount localhost:/ /mnt
>     ls -l /
>     umount /mnt
> 
>  the umount might fail.  This is because the "ls -l" tried to export every
>  filesystem found mounted in '/'.  The export of "/mnt" failed of course
>  because you cannot re-export an NFS filesystem.  But it is still in the
>  cache.
>  An 'exportfs -f' fixes this, but shouldn't be necessary.
> 
>  So this RFC patch makes it possible  to register a notifier which gets
>  called on unmount, and links the export table in to the notifier chain.
> 
>  The "atomic" flavour is used so that notifiers can be registered under a
>  spin_lock.  This is needed for "expkey_update" as ->update is called under a
>  lock.
> 
>  As notifier callees cannot unregister themselves, the unregister needs to
>  happen in a workqueue item, and the unmount will wait for that.
> 
>  It seems to work for me (once I figured out all the locking issues and found
>  a way to make it work without deadlocking).
> 
>  If you are OK with in in general I'll make it into a proper patch series and
>  include Al Viro for the VFS bits.

> @@ -1201,6 +1234,11 @@ static int do_umount(struct mount *mnt, int flags)
>  		sb->s_op->umount_begin(sb);
>  	}
>  
> +	/* Some in-kernel users (nfsd) might need to be asked to release
> +	 * the filesystem
> +	 */
> +	umount_notifier_call(mnt);

NAK.  I'm sorry, but it's a fundamentally wrong approach - there are _tons_
of places where vfsmount could get evicted (consider shared-subtree umount
propagation, for starters), not to mention that notifiers tend to be
the wrong answer to just about any question.

I'd suggest looking at what kernel/acct.c is doing; I'm absolutely serious
about notifiers being unacceptable BS.  If you want something generic,
consider turning ->mnt_pinned into a list of callbacks, with mntput_no_expire
calling them one by one; calling acct_auto_close_mnt() would be replaced with
callbacks, each doing single acct_file_reopen(acct, NULL, NULL).

I'm about to fall asleep right now, so any further details will have to wait
until tomorrow; sorry...

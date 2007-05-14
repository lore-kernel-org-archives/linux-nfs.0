From: Neil Brown <neilb@suse.de>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 15 May 2007 09:58:04 +1000
Message-ID: <17992.63372.522494.519874@notabene.brown>
References: <4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com> <462CFC92.2080201@amd.com>
	<463B97E6.4030009@amd.com>
	<1178314889.6533.19.camel@heimdal.trondhjem.org>
	<1178379473.4559.24.camel@raven.themaw.net>
	<1178385472.6561.43.camel@heimdal.trondhjem.org>
	<20070514131743.GG31764@petra.dvoda.cz>
	<1179149048.6858.5.camel@heimdal.trondhjem.org>
	<1179153555.3811.57.camel@raven.themaw.net>
	<1179157631.6474.8.camel@heimdal.trondhjem.org>
	<1179158812.3811.68.camel@raven.themaw.net>
	<17992.58783.827023.697258@notabene.brown>
	<1179184319.6467.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net,
	Ian Kent <raven@themaw.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnkQh-0005OK-NK
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 16:58:15 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnkQk-0005My-4H
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 16:58:18 -0700
In-Reply-To: message from Trond Myklebust on Monday May 14
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday May 14, Trond.Myklebust@netapp.com wrote:
> On Tue, 2007-05-15 at 08:41 +1000, Neil Brown wrote:
> > 
> > I would lean towards restoring the default to nosharedcache, and
> > having to explicitly request sharedcache if you want that, and are
> > happy to have the same mount option enforced on all sharing mounts.
> 
> I disagree with that. The default was changed for a very good reason,
> namely that people were making assumptions that were wrong: i.e. that
> the cache remains consistent when you change the ro/rw flag or try to
> mount a subdirectory.

And fixing the assumptions made by some people broken different
assumptions made by other people - a bit of a no-win situation I
guess.

> In fact, if you mounted the _same_ directory twice, then the default was
> always 'sharedcache'.

Ahh.. I didn't realise that.

> 
> So all we did in 2.6.18, was to make a consistent set of rules for how
> this works.
> 
> The default should therefore remain 'sharedcache', preferably returning
> an error if the user tries to mix metaphors.

Would we need to rev the mount_data version to add such a flag, or are
we sure that unused flags are 0, and so simply add

#define NFS_MOUNT_UNSHARED	0x8000 /* 5 */

(I don't understand the NFS_MOUNT_FLAGMASK.  Can the top 16 bits of
flags be used?)

If the "you have mixed metaphors" error was unique, the mount.nfs
program could conceivable respond to it by setting the UNSHARED flag,
trying again, and printing a big loud warning.... I wonder if that
would be a good idea...

But then what if you wanted sharedcache and weren't fussed about exact
options, how would mount.nfs handle that?   Finding a matching entry
in /etc/mtab would be hard because fsid matching would be non-trivial.
Maybe we want two flags "UNSHARED" and "SHARE_AND_IGNORE_MY_SETTINGS"??

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

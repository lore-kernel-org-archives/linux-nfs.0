From: Neil Brown <neilb@suse.de>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 15 May 2007 08:41:35 +1000
Message-ID: <17992.58783.827023.697258@notabene.brown>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ian Kent <raven@themaw.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnjEo-0006bR-6f
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 15:41:56 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnjEq-0007A8-Jl
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 15:41:57 -0700
In-Reply-To: message from Ian Kent on Tuesday May 15
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

On Tuesday May 15, raven@themaw.net wrote:
> On Mon, 2007-05-14 at 11:47 -0400, Trond Myklebust wrote:
> > 
> > We might then be able to add an '--unshared-cache' option (any
> > suggestions for a better name?) to mount in order to allow those people
> > who fully understand the consequences to override, and hence to mount
> > the same filesystem with different mount options, but no sharing of the
> > page cache with the original filesystem.
> 
> Not sure, perhaps "--force-options" or "--force-samefs-options".

Presumably this would be a mount option (-o xxx) rather than a new
flag to mount?  It would cause nfs_compare_super to return 0 if either
'data' or 'sb' contained the "no_share" flag.

I think "shared" is an important concept to have in there as it is
sharing the cache, the connection and the options.  For consistency
with other options, I would have an optional "no" at the front to
invert the flag.  Current nfs options don't have punctuation, so I
would probably go for something like:
       -o  [no]sharedcache
       -o  [no]shareconnection 

Then comes the question of what the default should be.
The original default was nosharedcache, but the more recent default
has been sharedcache.   In hindsight it would have been better not to
change the default, but things are always much clearer in hindsight.

I would lean towards restoring the default to nosharedcache, and
having to explicitly request sharedcache if you want that, and are
happy to have the same mount option enforced on all sharing mounts.

Having nosharedcache be the default would mean that sharedcache could
fail if other mount options are not an exact match, and there would be
no backward compatibility problem with that.


NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

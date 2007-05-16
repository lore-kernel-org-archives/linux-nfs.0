From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 15 May 2007 20:27:34 -0400
Message-ID: <1179275254.6464.88.camel@heimdal.trondhjem.org>
References: <4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com>
	<462CFC92.2080201@amd.com> <463B97E6.4030009@amd.com>
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
	<17992.63372.522494.519874@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net,
	Ian Kent <raven@themaw.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho7Mm-000848-N0
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 17:27:44 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ho7Mo-0008NT-1k
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 17:27:47 -0700
In-Reply-To: <17992.63372.522494.519874@notabene.brown>
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

On Tue, 2007-05-15 at 09:58 +1000, Neil Brown wrote:

> Would we need to rev the mount_data version to add such a flag, or are
> we sure that unused flags are 0, and so simply add
> 
> #define NFS_MOUNT_UNSHARED	0x8000 /* 5 */
> 
> (I don't understand the NFS_MOUNT_FLAGMASK.  Can the top 16 bits of
> flags be used?)

I don't see why not. It is a private field in a private data structure.
I've really never understood the point of that mask in the first place.

> If the "you have mixed metaphors" error was unique, the mount.nfs
> program could conceivable respond to it by setting the UNSHARED flag,
> trying again, and printing a big loud warning.... I wonder if that
> would be a good idea...
>
> But then what if you wanted sharedcache and weren't fussed about exact
> options, how would mount.nfs handle that?   Finding a matching entry
> in /etc/mtab would be hard because fsid matching would be non-trivial.
> Maybe we want two flags "UNSHARED" and "SHARE_AND_IGNORE_MY_SETTINGS"??

None of the other filesystems allow you to do this. They will simply
return EBUSY, and leave up to you to figure out what is wrong.

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect	sub-second
 timestamps on etab
Date: Thu, 26 Apr 2007 14:56:42 +1000
Message-ID: <17968.12554.934818.359167@notabene.brown>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgw2O-0001pG-Gw
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 21:57:12 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hgw2P-0000tY-IO
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 21:57:03 -0700
In-Reply-To: message from Chuck Lever on Wednesday April 25
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday April 25, chuck.lever@oracle.com wrote:
> 
> Hi Jeff-
> 
> I don't know much about the export logic, but why not use inode change 
> notification instead of time stamps?

inotify is 2.6 only I think.  I'm not sure I want to exclude 2.4
people just yet (or do I ??).

Given that exportfs replaces the file with a new one, would we need to
get notification on the directory, or just on the file?  Does it make
it more complicated, or easier?

Actually, mountd could open etab and hold it open. auth_reload could
stat "/var/lib/nfs/etab" and if it is a different file, then the
content is presumably different, while if it is the same file, we can
be certain the content is unchanged.

Further, we would be certain only to read each version once - zero
risk of re-parsing data when there is no change.

That might be an even better option .... anyone want to code it up??

Or is it wrong to depend on current exportfs behaviour?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: <trond.myklebust@fys.uio.no>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!" message?
Date: Wed, 21 Jan 2004 17:38:08 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <44242.68.42.103.198.1074703088.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjLMw-0004E6-K7
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 08:38:18 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjLMw-0000OQ-8q
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 08:38:18 -0800
To: <swampler@noao.edu>, <neilb@cse.unsw.edu.au>
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

På on , 21/01/2004 klokka 11:12, skreiv Steve Wampler:
> > Which filesystem are you using on your server?
>
> ext2

Hmm... Should be pretty stable.

> Client A:
>        Builds a new version of files locally and copies them over to
> server, replacing existing files.
>
> Client B:
>        Accesses files on server

> Might this be a timing issue of some sort, where client B
> accesses the file in the middle of the replacement?  (so it
> then is referencing the original (deleted on replacement)
> copy)?  I wouldn't think so, but know so little about NFS.

If the file is deleted, then LOOKUP shouldn't see it at all. Hmm...
Although nfsd_lookup() does indeed check for negative dentries, it does
not check if the inode->i_nlink is zero, and neither does
encode_diropres.

So if the lookup can race with a delete request on the server (which
apparently it can, since the VFS unlink never protects against lookup)
then the above can indeed happen.

It is still a bug, though. Neil?

Cheers,
  Trond





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

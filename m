From: <trond.myklebust@fys.uio.no>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!" message?
Date: Thu, 22 Jan 2004 08:06:55 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <38129.68.42.103.198.1074755215.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <swampler@noao.edu>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjYvf-0006pm-Mi
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 23:07:03 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AjYvf-00084X-9x
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 23:07:03 -0800
To: <neilb@cse.unsw.edu.au>
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

På to , 22/01/2004 klokka 01:08, skreiv Neil Brown:
> > It is still a bug, though. Neil?
>
> Is it?
> Does the spec say I cannot return nlink == 0   ?-)

Not explicitly. However implicitly, yes it does. The all attributes are
supposed to be
read _atomically_ with the lookup and a file with nlink == 0 could not be
looked up.

> The obvious alternative would be to return NFSERR_STALE if nlink seems
> to be 0, as the file is about to disappear, and a GETATTR request
> moments later would get STALE anyway.

No. LOOKUP should return either ENOENT or a valid file. ESTALE is not an
option unless the parent directory has been removed from underneath you.
Actually we are currently returning EIO to the user in this situation. It
seems stupid, though.

> But why does your client care if nlink == 0 or not?  And presumably if
> it really cared, it could interpret 'nlink == 0' as equivalent to
> NFSERR_STALE.

I care in cases where the user does an open(), particularly if it is an
open with create. Ditto in readdir/readdirplus.

What's more, if you allow races with unlink, then the clients can end up
in wierd states due to inconsistencies between cached attributes: a parent
directory with attributes that reflect the file not having been deleted at
the time when the post-op attributes were created, but the file itself
actually having been deleted on the server.

> I would be awkward with the current nfsd code to return a STALE error
> if nlink were zero, and we don't copy nlink out of the inode until
> after we have encoded the reply code.

Again, see the atomicity requirements.

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

From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!" message?
Date: Thu, 22 Jan 2004 17:08:38 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16399.26854.924556.244905@notabene.cse.unsw.edu.au>
References: <44242.68.42.103.198.1074703088.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <swampler@noao.edu>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjY1P-0000Dz-QD
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 22:08:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AjY1P-0004UI-EN
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 22:08:55 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <trond.myklebust@fys.uio.no>) (for <swampler@noao.edu>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 22 Jan 2004 17:08:39 +1100
To: <trond.myklebust@fys.uio.no>
In-Reply-To: message from trond.myklebust@fys.uio.no on Wednesday January 21
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

On Wednesday January 21, trond.myklebust@fys.uio.no wrote:
> 
> > Might this be a timing issue of some sort, where client B
> > accesses the file in the middle of the replacement?  (so it
> > then is referencing the original (deleted on replacement)
> > copy)?  I wouldn't think so, but know so little about NFS.
> 
> If the file is deleted, then LOOKUP shouldn't see it at all. Hmm...
> Although nfsd_lookup() does indeed check for negative dentries, it does
> not check if the inode->i_nlink is zero, and neither does
> encode_diropres.
> 
> So if the lookup can race with a delete request on the server (which
> apparently it can, since the VFS unlink never protects against lookup)
> then the above can indeed happen.
> 
> It is still a bug, though. Neil?

Is it?
Does the spec say I cannot return nlink == 0   ?-)


The obvious alternative would be to return NFSERR_STALE if nlink seems
to be 0, as the file is about to disappear, and a GETATTR request
moments later would get STALE anyway.

But why does your client care if nlink == 0 or not?  And presumably if
it really cared, it could interpret 'nlink == 0' as equivalent to
NFSERR_STALE.

I would be awkward with the current nfsd code to return a STALE error
if nlink were zero, and we don't copy nlink out of the inode until
after we have encoded the reply code.

I guess I could force it to 1 if it were 0, on the basis that it
probably was 1 very recently....

NeilBrown


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

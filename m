From: <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS client doesn't flush dirty mmap'd pages during fsync/msync
Date: Tue, 20 Jan 2004 14:31:05 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35223.68.42.103.198.1074605465.squirrel@webmail.uio.no>
References: <Pine.BSO.4.33.0401141300540.10050-100000@citi.umich.edu>
        <20040120120116.GP17993@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <cel@citi.umich.edu>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AivyN-0003vh-GG
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 05:31:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AivyN-0001Dk-2c
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 05:31:15 -0800
To: <okir@suse.de>
In-Reply-To: <20040120120116.GP17993@suse.de>
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

> Given that we have the inode for these dirty pages, couldn't we at least
> compare the req->wb_inode to filp->f_dentry->d_inode?

I believe that is indeed what Chuck's patch does. Previously we would in
addition check that the filp matches. For ordinary files that is fine, but
in the special case of msync(MS_SYNC), it was causing the fsync() method
to skip precisely those dirty pages that we wanted to sync to disk.

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

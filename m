From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Wed, 12 Nov 2003 16:18:34 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16306.41898.291062.36209@charged.uio.no>
References: <3FB27670.4C878A84@psu.edu>
	<shssmkttk34.fsf@charged.uio.no>
	<3FB29D43.A618973D@psu.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AK2Nt-00026m-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 13:18:41 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AK2Ns-0003t7-VB
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 13:18:41 -0800
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <3FB29D43.A618973D@psu.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Jason Holmes <jholmes@psu.edu> writes:

     > Client nfs v3: null getattr setattr lookup access readlink 0 0%
     > 744 0% 0 0% 129 0% 252 0% 0 0% read write create mkdir symlink
     > mknod 873 0% 178574 14% 24 0% 0 0% 0 0% 0 0% remove rmdir
     > rename link readdir readdirplus 24 0% 0 0% 0 0% 0 0% 18 0% 0 0%
     > fsstat fsinfo pathconf commit 0 0% 3 0% 0 0% 1023451 84%

     > Client rpc stats: calls retrans authrefrsh 1204092 3 0

Something is seriously screwed up here: it should be impossible to get
more commit requests than there are write requests.

Basically, commit is only sent if at least one unstable write has been
sent, and is waiting on the commit list. The commit list itself is
emptied before the RPC call gets sent. If the commit fails, it
resends all pending writes.

IOW: it looks like you are seeing some form of list corruption. I
suspect that the problem here might be something scribbling over the
nfs_inode. Are you running with slab debugging, and stack overflow
enabled?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

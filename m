From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: type check in fh_verify()
Date: Sat, 27 Jul 2002 23:13:58 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0207272311170.18815-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YeVP-0004sQ-00
	for <nfs@lists.sourceforge.net>; Sat, 27 Jul 2002 20:14:03 -0700
Received: from vanguard.gpcc.itd.umich.edu (vanguard.gpcc.itd.umich.edu [141.211.2.216])
        by berzerk.gpcc.itd.umich.edu (8.8.8/4.3-mailhub) with ESMTP id XAA00939
        for <nfs@lists.sourceforge.net>; Sat, 27 Jul 2002 23:13:59 -0400 (EDT)
Received: from localhost (kmsmith@localhost)
	by vanguard.gpcc.itd.umich.edu (8.9.1a/5.1-client) with ESMTP id XAA18923
	for <nfs@lists.sourceforge.net>; Sat, 27 Jul 2002 23:13:59 -0400 (EDT)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


In fs/nfsd/nfsfh.c:fh_verify(), the following block of code is
responsible for type checking:

	/* Type check. The correct error return for type mismatches
	 * does not seem to be generally agreed upon. SunOS seems to
	 * use EISDIR if file isn't S_IFREG; a comment in the NFSv3
	 * spec says this is incorrect (implementation notes for the
	 * write call).
	 */

	/* Type can be negative when creating hardlinks - not to a dir */
	if (type > 0 && (inode->i_mode & S_IFMT) != type) {
		error = (type == S_IFDIR)? nfserr_notdir : nfserr_isdir;
		goto out;
	}
	if (type < 0 && (inode->i_mode & S_IFMT) == type) {
		error = (type == -S_IFDIR)? nfserr_notdir : nfserr_isdir;
		goto out;
	}

I think that the assignment in the last block is backwards and should be

		error = (type == -S_IFDIR)? nfserr_isdir : nfserr_notdir;

Also, how about changing the assignment in the first block to

		if (type == S_IFDIR)
			error = nfserr_notdir;
		else if ((inode->i_mode & S_IFMT) == S_IFDIR)
			error = nfserr_isdir;
		else
			error = nfserr_inval;
		goto out;

to be consistent with the comment?

Cheers,
 Kendrick




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

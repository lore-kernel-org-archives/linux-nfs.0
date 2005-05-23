From: Jack Neely <jjneely@pams.ncsu.edu>
Subject: nfs_statfs64: statfs error = 2
Date: Mon, 23 May 2005 15:29:18 -0400
Message-ID: <20050523192918.GX17945@anduril.pams.ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DaIc4-0002Jd-UX
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 12:29:20 -0700
Received: from anduril.pams.ncsu.edu ([152.1.120.18])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DaIc3-0001EA-3w
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 12:29:20 -0700
Received: from anduril.pams.ncsu.edu (localhost.localdomain [127.0.0.1])
	by anduril.pams.ncsu.edu (8.12.11/8.12.11) with ESMTP id j4NJTILP024168
	for <nfs@lists.sourceforge.net>; Mon, 23 May 2005 15:29:18 -0400
Received: (from slack@localhost)
	by anduril.pams.ncsu.edu (8.12.11/8.12.11/Submit) id j4NJTIv4024166
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 15:29:18 -0400
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi,

I'm getting some pecular NFS behavior that google seems to know nothing
about.  

I have two very special users on my Beowulf.  When autofs tries to
unmount their home directories the mount points go stale wheather the
users are accessing the directory or not.

The ls command reports no file or directory.  If I cd into to the
directory that works but the directory is a stale NFS handle.

My logs report "May 23 15:04:27 login-1 kernel: nfs_statfs64: statfs
error = 2".  Ocasionally, I also receive "nfs_notify_change: revalidate
failed, error=-2".

File server is a RHEL 4 machine running 2.6.9-5.ELsmp.  Clients are
running RHEL 3 2.4.21-27.0.2.ELsmp.

Any suggestions?

Jack Neely
-- 
Jack Neely <slack@quackmaster.net>
Realm Linux Administration and Development
PAMS Computer Operations at NC State University
GPG Fingerprint: 1917 5AC1 E828 9337 7AA4  EA6B 213B 765F 3B6A 5B89


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

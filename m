From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: historical question: nfs_rename()
Date: Mon, 17 Oct 2005 12:12:14 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERaPU-0002ps-EM
	for nfs@lists.sourceforge.net; Mon, 17 Oct 2005 12:12:36 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ERaPS-0005Jb-VC
	for nfs@lists.sourceforge.net; Mon, 17 Oct 2005 12:12:36 -0700
Received: from svlexc02.hq.netapp.com (svlexc02.corp.netapp.com [10.57.157.136])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id j9HJCFI8011913
	for <nfs@lists.sourceforge.net>; Mon, 17 Oct 2005 12:12:29 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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

a customer recently pointed out that the rename(2) system call does not
allow replacing directories, even if they are empty.  RFC1813 at least
suggests that the server and protocol do allow directory replacement, as
long as the target is empty.

the culprit appears to be this check in nfs_rename()

        if (S_ISDIR(new_inode->i_mode))
                goto out;

which causes nfs_rename() to return -EBUSY if the target is a directory.

is there a historical reason why the Linux NFS client does not allow
directory replacement?  shouldn't the error code be -EISDIR for this
case?

        - Chuck Lever
--
corporate:     <cel at netapp dot com>
personal:      <chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

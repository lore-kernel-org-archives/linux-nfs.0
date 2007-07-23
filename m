From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: bug : sm-notify path is hardcoded into statd
Date: Mon, 23 Jul 2007 18:15:28 +0200
Message-ID: <46A4D420.1040801@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ID0ZM-0000GD-Nn
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 09:15:38 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ID0ZN-0004Ek-KC
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 09:15:40 -0700
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

Hi,

Just found another which happens when nfs utilities are not installed in 
/usr/sbin (e.g. because it's installed in /sbin for a diskless setup), 
statd can't properly call sm-notify because the path to sm-notify is 
hardcoded at utils/statd/statd.c:226 (nfs-utils-1.1.0). To preserve 
consistency with configure switch, we must instead replace it with the 
sbindir variable. (I can't reliably do a patch because I don't know 
enough how to deal with the autotools).

Thanks,

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Josh Tasman <tasman@u.washington.edu>
Subject: serving 2.4 binaries from 2.6?
Date: Mon, 03 Oct 2005 12:29:03 -0700
Message-ID: <4341867F.2070104@u.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EMVzv-0000Qh-MP
	for nfs@lists.sourceforge.net; Mon, 03 Oct 2005 12:29:15 -0700
Received: from mxout7.cac.washington.edu ([140.142.32.178])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EMVzs-00063Y-Cs
	for nfs@lists.sourceforge.net; Mon, 03 Oct 2005 12:29:15 -0700
Received: from smtp.washington.edu (smtp.washington.edu [140.142.32.139])
	by mxout7.cac.washington.edu (8.13.4+UW05.04/8.13.4+UW05.09) with ESMTP id j93JT67P025710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Mon, 3 Oct 2005 12:29:06 -0700
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


Our lab has a mix of Fedora Core 1 and 4 machines.  I'd like to set up a
fileserver, preferably with FC4.  Does anyone have any pointers for
serving 2.4 binaries from a 2.6 machine?

Should 2.4 applications first be installed on a (client) 2.4 machine,
and then moved to the server?  I'm hoping that correct 2.4 dynamically
linked libraries would be found on the 2.4 client (if library
directories aren't exported-- i.e. apps exported from /usr/local/2.4 and
/usr/local/2.6 )

Thanks,

Josh



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: new NFS FAQ questions
Date: Wed, 23 Mar 2005 07:21:32 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085398ED@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE7g4-00035L-RG
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 07:21:48 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DE7g3-0007yE-Ei
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 07:21:48 -0800
Received: from svlexc02.hq.netapp.com (svlexc02.corp.netapp.com [10.57.157.136])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id j2NFLYCu012729
	for <nfs@lists.sourceforge.net>; Wed, 23 Mar 2005 07:21:42 -0800 (PST)
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

three new questions appear today:

A9. Why does opening files with O_APPEND on multiple clients cause the
files to become corrupted?

D10. I'm trying to use flock()/BSD locks to lock files used on multiple
clients, but the files become corrupted. How come?

D11. Why doesn't "mount -oremount,tcp" convert an NFS-mounted file
system mounted with UDP to one mounted with TCP?

i've also added links to some NFS-related blogs in the Quick Overview
section.

        - Chuck Lever
--
corporate:     <cel at netapp dot com>
personal:      <chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

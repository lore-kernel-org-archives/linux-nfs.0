From: David Dougall <davidd@et.byu.edu>
Subject: file system handle
Date: Mon, 13 Dec 2004 08:12:28 -0700 (MST)
Message-ID: <Pine.LNX.4.58.0412130809570.13290@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CdrsT-0002uk-OZ
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 07:12:45 -0800
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CdrsT-0008Ml-Aw
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 07:12:45 -0800
Received: from lewis.et.byu.edu (lewis.et.byu.edu [128.187.112.50])
	by postal1.et.byu.edu (8.12.10/8.12.10) with ESMTP id iBDFCSSn030375
	for <nfs@lists.sourceforge.net>; Mon, 13 Dec 2004 08:12:28 -0700
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

I am moving filesystems/disks to new NFS servers.  They are going to
change major and minor numbers.  Is there any way I can prevent stale
mounts with the fsid= option in the exports?
I have tried this on a test environment, but when I try to create an fsid=
option, it completely changes the filehandle format in the nfs packet.  Am
I missing something, or are the default and forced fsid options
incompatible?
--David Dougall



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

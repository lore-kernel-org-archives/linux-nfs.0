From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Problems with fh_fsid_type=3 exports (device minor id > 255)
Date: Fri, 26 May 2006 11:48:39 -0700
Message-ID: <1148669319.12795.44.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FjhKB-00051X-5k
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 11:46:15 -0700
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FjhK6-0000xe-TA
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 11:46:12 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4QIk5Iw017576
	for <nfs@lists.sourceforge.net>; Fri, 26 May 2006 14:46:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4QIk4k7140556
	for <nfs@lists.sourceforge.net>; Fri, 26 May 2006 12:46:04 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4QIk4Vt028340
	for <nfs@lists.sourceforge.net>; Fri, 26 May 2006 12:46:04 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4QIk3sX027775
	for <nfs@lists.sourceforge.net>; Fri, 26 May 2006 12:46:04 -0600
To: NFS List <nfs@lists.sourceforge.net>
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

I having a problem with the 2.6.9 kernel and mounting file systems with
a minor device id > 255 where the mount fails. It seems like the file
handle is never cached. We are able to proceed if fsid is specified
in /etc/exports. nfs-utils version is 1.0.6.

Have others seen this problem and is there a fix in a later kernel?

I've been trying to follow the fh_compose and fh_verify code to
understand this, but I don't see where there's a difference between type
3 file handles and type 1 file handles (fsid specified in /etc/exports)
that could cause a problem. When I add a little bit of debug messages, I
see that expkey_parse is being called as a result of a system call for
the type 1 handles, but not for the type 3 handles.

Thanks

Frank Filz




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

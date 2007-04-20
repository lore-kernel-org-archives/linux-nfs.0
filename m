From: David Warren <warren@atmos.washington.edu>
Subject: Re: NFS caching problem
Date: Fri, 20 Apr 2007 10:35:33 -0700
Message-ID: <4628F9E5.9040702@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hex1K-0002pN-8O
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 10:35:42 -0700
Received: from dew2.atmos.washington.edu ([128.95.89.42])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hex1L-0002nU-LV
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 10:35:44 -0700
Received: from [128.95.175.151] (warren@dee.atmos.washington.edu
	[128.95.175.151]) (authenticated bits=0)
	by dew2.atmos.washington.edu (8.13.4/8.13.4/Debian-3sarge3) with ESMTP
	id l3KHZXMb017834
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Fri, 20 Apr 2007 10:35:33 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I was a little too quick to blame it on gfs. I can now replicate it on 
systems that have never been in the presence of a gfs or dlm module. It 
is very consistent under V4. The only catch is you do have to get a new 
inode when you  recreate the file. The client does seem to pick up 
changes in the same inode number. However, I have still not been able to 
replicate it under V3 on these systems.

It seems like this is something that everyone should be seeing, so I am 
guessing that we must have something odd in our setup. Any suggestions? 
Here are all the NFS options from my config:
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_TCP=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y

-- 
David Warren 		INTERNET: warren@atmos.washington.edu
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Craig Tierney <ctierney@hpti.com>
Subject: Issue with nfs v3, linux-2.4.21, xfs, and fsx-linux
Date: Tue, 10 Feb 2004 15:52:22 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1076453542.2468.33.camel@hpti9.fsl.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqglC-00027G-Pm
	for nfs@lists.sourceforge.net; Tue, 10 Feb 2004 14:53:42 -0800
Received: from [208.20.6.201] (helo=hptimail01.HPTI.COM)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aqgky-00007D-Uo
	for nfs@lists.sourceforge.net; Tue, 10 Feb 2004 14:53:29 -0800
To: nfs@lists.sourceforge.net
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

Should I be able to successfully run fsx-linux over
NFS?  My server is linux-2.4.21 with xfs-1.3.1.  I am
mounting:

 "udp,hard,intr,rw,async,nolock,wsize=8192,rsize=8192,timeo=30"

My scsi driver is qla2200, ver 6.06.10.

My client is linux-2.4.20 with nfs patches from Trond's 
directory.

If I run fsx-linux on the filesystem directly, it runs fine.
If I run it over the NFS mount, it will crash with an error
within 30 seconds.

Should fsx-linux work properly over NFS?

Thanks,
Craig



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

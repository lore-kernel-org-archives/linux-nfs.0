From: Andreas Gruenbacher <agruen@suse.de>
Subject: Native NFSv4 ACLs on Linux
Date: Fri, 14 Jul 2006 16:37:32 +0200
Message-ID: <200607141637.32246.agruen@suse.de>
Reply-To: nfsv4@ietf.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1Ol3-000758-SP
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 07:35:11 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G1Ol2-0005CG-DP
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 07:35:09 -0700
To: nfsv4@ietf.org, nfs@lists.sourceforge.net
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

Hello,

This is to announce a prototype that implements NFSv4 ACLs natively on Linux. 
So far, the implementation supports NFSv4 ACLs on Ext3 filesystems. The code 
is functional, but hasn't seen a whole lot of testing so far.

NFSv4 ACLs per se do not map to the POSIX permission model and the extension 
mechanisms that POSIX allows very well. Different designs to extend the 
definition of NFSv4 ACLs in order to make them map better to POSIX have been 
proposed. A conclusion which design to adopt for NFSv4 Minor Version 1 has 
not been reached so far. See the nfsv4@ietf.org mailing list 
(http://www1.ietf.org/mailman/listinfo/nfsv4) for discussions.

This prototype features a design that is relatively close to POSIX 1003.1e 
draft 17 ACLs as implemented on many flavors of UNIX. Until a formal design 
document is available, please refer to the discussion in the following two 
threads on the nfsv4@ietf.org mailing list, and read the code: 

  NFSv4 ACL and POSIX interaction / mask
    http://www1.ietf.org/mail-archive/web/nfsv4/current/msg03268.html

  NFSv4 ACL and POSIX interaction / mask, draft-ietf-nfsv4-acls-00 not ready
    http://www1.ietf.org/mail-archive/web/nfsv4/current/msg03286.html

The prototype itself is available at http://www.suse.de/~agruen/nfs4acl/, 
along with some more information.

Regards,
Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

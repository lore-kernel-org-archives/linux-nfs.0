From: Bull Barry - bbull <Barry.Bull@acxiom.com>
Subject: Problems with FTP to NFS mount dying...
Date: Wed, 23 Oct 2002 10:09:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <9DDD9C3004ADD3119C48009027DE532D17B85A46@conmsx02.corp.acxiom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from aerynsun.acxiom.com ([65.64.17.121])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184N8S-0006uC-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 08:09:28 -0700
Received: from conmsc01.conway.acxiom.com (unverified) by aerynsun.acxiom.com
 (Content Technologies SMTPRS 4.2.10) with ESMTP id <T5e1d2305f6414011795f8@aerynsun.acxiom.com> for <nfs@lists.sourceforge.net>;
 Wed, 23 Oct 2002 10:09:20 -0500
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I am ftp'ing a file from a Tru64 5.1A server to a directory on a Red Hat 7.1
server which is NFS mounted to another Tru64 5.1A. The file is approximately
40GB and is failing but not at any particular size. I am stumped as to where
I can look to resolve the problem or find error messages and was wondering
if anyone could offer any help. Also, are there any diagostic tools for NFS?




*********************************************************************

The information contained in this communication is
confidential, is intended only for the use of the recipient
named above, and may be legally privileged.
If the reader of this message is not the intended
recipient, you are hereby notified that any dissemination, 
distribution, or copying of this communication is strictly
prohibited.
If you have received this communication in error,
please re-send this communication to the sender and
delete the original message or any copy of it from your
computer system. Thank You.



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

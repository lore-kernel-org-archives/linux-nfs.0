From: "Sundareswar Jayakumar" <sundar@cdacb.ernet.in>
Subject: query
Date: Tue, 21 Oct 2003 16:39:36 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <NGBBKDKMALCPDNMIPMPLKENFCAAA.sundar@cdacb.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABz3Q-0003yH-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 09:08:16 -0700
Received: from cdacb.ernet.in ([202.141.63.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ABuPY-0001DP-48
	for nfs@lists.sourceforge.net; Tue, 21 Oct 2003 04:10:48 -0700
Received: from sundar (sundar.ctsf.cdac.org.in [192.168.60.102])
	by cdacb.ernet.in (8.12.9/8.12.9) with SMTP id h9LGo8sO018205
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 16:50:08 GMT
To: <nfs@lists.sourceforge.net>
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

Hi,
	I am working on adistributed filesytem on linux.I am using
nfs source code as a learning resource.I require a clarification.


In many entry points the Big Kernel Lock lock/unlock_kernel is
used instead of locking just the private data structures of the
filesystem.why is it so?.kindly clarify w.r.t to a smp m/c.

Thanks
sundar


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

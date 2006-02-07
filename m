From: "L. D. Marks" <L-marks@northwestern.edu>
Subject: Broken nfs
Date: Mon, 6 Feb 2006 18:50:05 -0600 (CST)
Message-ID: <Pine.GHP.4.63.0602061838200.2906@risc4.numis.northwestern.edu>
Reply-To: "L. D. Marks" <L-marks@northwestern.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6H3c-00065O-9m
	for nfs@lists.sourceforge.net; Mon, 06 Feb 2006 16:50:12 -0800
Received: from risc4.numis.northwestern.edu ([129.105.122.70])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F6H3a-0005fk-1X
	for nfs@lists.sourceforge.net; Mon, 06 Feb 2006 16:50:12 -0800
Received: from localhost (ldm@localhost)
	by risc4.numis.northwestern.edu (8.9.3 (PHNE_28760_binary)/8.9.3) with ESMTP id SAA03035
	for <nfs@lists.sourceforge.net>; Mon, 6 Feb 2006 18:50:05 -0600 (CST)
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

I appear to have a broken nfs. With normal nfs mount of a directory (not 
automount, which appears to hide the problem)
the script on the server:

echo 10 > Probe
ssh -x c0-0 cat Probe
echo 11 > Probe
ssh -x c0-0 cat Probe

Will report 10 & 11 the first time, but afterwards 10 & 10. I attempted 
changing the attributes in the client
/etc/fstab even using noac but this does not change anything. Any ideas 
welcome.

Partial OS details (more available if needed)
Linux 2.6.9-22.0.2.ELsmp #1 SMP
nfs-utils-1.0.6-65.EL4

-----------------------------------------------
Laurence Marks
Department of Materials Science and Engineering
MSE Rm 2036 Cook Hall
2220 N Campus Drive
Northwestern University
Evanston, IL 60201, USA
Tel: (847) 491-3996 Fax: (847) 491-7820
email: L-marks at northwestern dot edu
http://www.numis.northwestern.edu
-----------------------------------------------



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

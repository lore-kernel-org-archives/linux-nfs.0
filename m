From: "Merritt Krakowitzer" <merrittk@sira-sa.co.za>
Subject: nfs mounted homedirs with gnome problem.
Date: Wed, 28 Jan 2004 13:50:15 +0200 (SAST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <43541.192.168.1.8.1075290615.squirrel@webmail.sira-sa.co.za>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Alo6R-0000q0-Mn
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 03:43:27 -0800
Received: from [196.25.66.66] (helo=sira-sa.co.za)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Alo6K-0000Cs-OA
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 03:43:26 -0800
Received: from perrin.sira-sa.co.za (perrin.sira-sa.co.za [192.168.1.3])
	by sira-sa.co.za (Postfix) with ESMTP id 6092336672
	for <nfs@lists.sourceforge.net>; Wed, 28 Jan 2004 06:33:59 +0200 (SAST)
Received: from webmail.sira-sa.co.za (localhost [127.0.0.1])
	by perrin.sira-sa.co.za (Postfix) with SMTP id 4C669DD36
	for <nfs@lists.sourceforge.net>; Wed, 28 Jan 2004 13:50:15 +0200 (SAST)
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

Hi

i have a problem which i hope someone can help me with, I have nfs mounte=
d
home directories which are accessed by gnome workstations, when I log in
for the first time from a workstation, gnome loads fine, when I reboot th=
e
workstation and login, gnome seems to hang

If I login into the console with the username or cd to the users hom dir
on the workstation, gnome completes loading.

I have just one error in the log files
nfs: server nfs.foo.bar not responding, still trying.

When I cd to the homedir of the user I get this in the logs
nfs: server nfs.foo.bar OK

Im running Gentoo Linux with kernel ver 2.6.1 on both the server and
workstations over a 1000baseT network.

If someone could push me in the right direction please?.

I dont believe this is related to FAQ about:
  D4. I frequently see this in my logs:

  kernel: nfs: server server.domain.name not responding, still trying
  kernel: nfs: task 10754 can't get a request slot
  kernel: nfs: server server.domain.name OK

Regards
--=20
Merritt Krakowitzer


-----------------------------------------
Disclaimer Legal Notice:
By having opened and read this electronic mail, you are
deemed to have understood and accepted all disclaimers and
conditions pertaining to electronic mail emanating from and
received by the Private Security Industry Regulatory Authority,
further detail of which may be viewed at the following link:
http://www.sira-sa.co.za/disclaimer.htm


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

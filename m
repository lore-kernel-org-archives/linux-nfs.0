From: jeremy@mcnicoll.ca
Subject: IOStat with NFS
Date: Sun,  7 Dec 2003 15:37:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070829440.3fd38f808706e@www.mcnicoll.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jeremymc@sce.carleton.ca
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AT5ej-00038W-DP
	for nfs@lists.sourceforge.net; Sun, 07 Dec 2003 12:37:29 -0800
Received: from cpu1981.adsl.bellglobal.com ([206.47.37.212] helo=mcnicoll.ca)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AT5ei-0001AO-SY
	for nfs@lists.sourceforge.net; Sun, 07 Dec 2003 12:37:29 -0800
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

As a project for school (engineering) I modified IOStat on a 2.4.22 or 23 
series kernel to allow for NFS data output.  This may be useful for some people 
here.  I am in the middle of exams, so I cant get back to anyone too quickly on 
this but if any one is interested in what I did the patches are here. 

http://www.mcnicoll.ca/iostatnfs/iostats.html

Hopefully people can give me constructive criticism on this work since its 
getting marked and I would like to see community acceptance. 

Any pointers, tips, useful info to help towards the report that I have to write 
would be greatly appreciated. 

Some of the things to be done when I finish exams are: 
  -clean up code.
  -look at getting it working on 2.6 since there are no more changes to 2.4
  -report bug on the disk stats that  I found while doing the work.
  -try to get this worked into the kernel. 
  -Use the feedback that I get to help with the documenation. 

Thank you. 




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

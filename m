From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: Re: nfs server tcp support
Date: Thu, 9 Oct 2003 12:49:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFA546FE32.E52E1971-ON88256DBA.006C720E-88256DBA.006CE48D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7gnS-0004kZ-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Oct 2003 12:50:02 -0700
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A7gnR-0001Vg-UA
	for nfs@lists.sourceforge.net; Thu, 09 Oct 2003 12:50:02 -0700
To: "Eno Compton" <Eno.Compton@Miltope.com>
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





Note that in xconfig the "Provide NFS Server over TCP support" is grayed
out because it is considered EXPERIMENTAL (which is also displayed).  To
enable it, select  'y' for "Prompt for development and/or incomplete
code/drivers" found under "Code maturity level options" in the main menu.
Although it is still considered experimental on 2.4, it has been quite
solid.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                         
                      "Eno Compton"                                                                                                      
                      <Eno.Compton@Miltope        To:       <nfs@lists.sourceforge.net>                                                  
                      .com>                       cc:                                                                                    
                      Sent by:                    Subject:  [NFS] nfs server tcp support                                                 
                      nfs-admin@lists.sour                                                                                               
                      ceforge.net                                                                                                        
                                                                                                                                         
                                                                                                                                         
                      10/09/2003 12:38 PM                                                                                                
                                                                                                                                         
                                                                                                                                         




The NFS project home page states, "The 2.4.19 kernel integrates server
support for NFS over TCP", which makes me think nfs server support for tcp
is present.

But the Linux NFS-HOWTO states, "A new feature, available for both 2.4 and
2.5 kernels but not yet integrated into the mainstream kernel at the time
of this writing, is NFS over TCP", which makes me think nfs server support
for tcp is absent.

make xconfig on kernel 2.4.21 has an option for, "Provide NFS Server over
TCP support" grayed out, which confuses me.

I'm trying to get NFS server support going in RH 9 which uses kernel 2.4.20
and striking out every way I turn.

Would anybody care to advise how I should proceed, please?

Eno Compton


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs





-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

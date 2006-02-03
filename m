From: Steven Stromer <filter@stevenstromer.com>
Subject: SFU to NFS Returns Error: "The semaphore timeout period has expired"
Date: Fri, 03 Feb 2006 11:38:55 -0500
Message-ID: <ds00v2$tf7$1@sea.gmane.org>
Reply-To: filter@stevenstromer.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F54lz-0000Yl-Mk
	for nfs@lists.sourceforge.net; Fri, 03 Feb 2006 09:31:03 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F54lx-0007yl-7c
	for nfs@lists.sourceforge.net; Fri, 03 Feb 2006 09:31:03 -0800
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1F54lX-0006fY-TS
	for nfs@lists.sourceforge.net; Fri, 03 Feb 2006 18:30:36 +0100
Received: from ip207-101-85-242.z85-101-207.customer.algx.net ([207.101.85.242])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Fri, 03 Feb 2006 18:30:35 +0100
Received: from filter by ip207-101-85-242.z85-101-207.customer.algx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Fri, 03 Feb 2006 18:30:35 +0100
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

We have a Fedora server hosting files that need to be accessed by one 
LINUX, one Mac and one WIN box (three developers working on one 
website), and have opted for NFS over Samba. The LINUX and MAC boxes 
were no problem - The exported shares on the Fedora box are all set to 
map to one user/group account, which serves our purposes just fine for 
the moment, so no real directory services are needed there. We are not 
running NIS, Active Directory or any other directory service. There are 
simply not enough machines to make it worth the configuration time just yet.

Another key point to this network is that all three 'client' machines 
are connecting to the Fedora server via the public internet. Presently, 
we are limited to firewall, password, and NFS configuration protection, 
but we'll eventually force all these connections through encrypted VPNs.

On the Windows XP box, I have installed Client for NFS, Server For 
PCNFS, and User Name Mapping. On this machine there are simple maps 
containing the one user and the one group that need to match the Fedora 
box. After much configuration experimentation, I have finally got to the 
point where when mapping the share form the Win XP box to the Fedora 
box, I receive a 'NFS Login Successful' box displaying the correct 
UserName, UID and Primary GID. In this box, I click 'Yes' to accept the 
current login, as the window prompts. I wait for 30 seconds for the 
connection to complete, and the map to be created, but I receive the 
error "The semaphore timeout period has expired", and the connection 
never completes.

Usually, around this time, if I go to a command prompt, and attempt to 
use the 'mapadmin' command for anything, like 'list' I receive the error 
"Unable to perform the requested operation as the mapping service cannot 
be contacted." This seems strange, because I'm assuming that the mapping 
service was just used to reach the point of seeing the 'NFS Login 
Successful' box mentioned earlier. Am I missing some large server part 
that needs to be installed, is having one Win box providing its own User 
Name Mapping and PCNFS insufficient for consistent mapping service 
availability, or is there some simple timout setting that will help me 
to get past the semaphore timeout error? I have searched high and low 
for an answer. I feel so close, yet so far...

Thanks for an assistance!

Steven Stromer



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Michael <mogmios@mlug.missouri.edu>
Subject: auto-discovery of exports?
Date: Wed, 07 Apr 2004 01:03:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4073B5D5.3050507@mlug.missouri.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BB82U-0004Aq-6k
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 01:04:02 -0700
Received: from 100m.mpr200-1.esr.lvcm.net ([24.234.0.78] ident=mirapoint)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BB82U-0004GG-3V
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 01:04:02 -0700
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

Windows with the SFU add-on, allowing it to work as an NFS client, 
manages to scan my network for NFS servers and then show the exported 
filesystem under each of those servers. How could I implement the same 
thing in Linux?

I ask because I want to write a program that autoscans my network for 
certain files (images, music, video) that are readable and displays them 
in a nice viewer to the user without needing to go searching for them. I 
want the system to be flexible enough that it can allow machines to be 
plugged in and out of the network and still detect those shared files 
when available without any effort by the user.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

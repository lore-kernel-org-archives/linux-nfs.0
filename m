From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NSM lock recovery fails too often
Date: Tue, 9 Mar 2004 06:15:13 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DD1F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0i9o-0002qd-TI
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:24:32 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0hd4-000734-5d
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 05:50:42 -0800
To: "Olaf Kirch" <okir@suse.de>
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

hi olaf-

> Here's the promised sm-notify utility.

looks clean!

i thought the purpose of moving NSM into the kernel was
to eliminate the need for any user-level programs because
sometimes they don't get run at reboot..?

one of the issues we've observed with reboot notification
is that it fails entirely if the network stack on the client
hasn't been initialized when NSM starts.  for example, if a
client is DHCP configured, and the DHCP service is slow,
the NSM reboot notification will run and fail before the
client's network has been configured.  it also means that
the success of NSM reboot recovery is entirely dependent
on exactly when this program is run during start up.

how does your recovery program handle this case?


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

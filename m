From: Carl Gherardi <carl.gherardi@nautronix.com.au>
Subject: Stale NFS file handles
Date: Fri, 16 Jul 2004 12:11:02 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1089951062.6823.62.camel@coeus.nautronix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BlK3l-0000mb-Hh
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 21:10:57 -0700
Received: from 077.005.dsl.pth.iprimus.net.au ([203.134.183.77] helo=isa-fremantle.nautronix)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BlK3k-0003l3-PP
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 21:10:57 -0700
Received: from [10.61.1.105] (coeus.nautronix [10.61.1.105])
    by network.nautronix (8.12.9/) with ESMTP id i6G436os013801
    for <nfs@lists.sourceforge.net>; Fri, 16 Jul 2004 12:03:06 +0800 (WST)
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

Hey all,

I'm consistently getting stale file handles on my setup here, and i'm
not sure whether it is a fault of the applications or nfs.

Setup:

Redhat 7.3 server (nfs-utils-0.3.3-6.73) exporting /export/home/username
(individual exports for every user not exporting /export/home) using rw,
root_squash
Redhat 9 client (nfs-utils-1.0.1-3.9) automounting /home/username from
Redhat 7.3 machine using nis

To make stale file handles appear:

Clients log into Redhat 9 server using ssh with default shell of zsh. 

A new user arrives, so I add an export to 7.3 server, alter the nis map
then run exportfs -r and /var/yp/make

Very quickly every mount under /home on the Redhat 9 server becomes
stale, and doesn't recover.

To fix stale file handles:

exportfs -r on 7.3 server _temporarily_ fixes the problem, and all
mounts become "fresh" again, but within the hour all the mounts become
stale again.

Manually unmounting the directories then mounting them again (using cd)
fixes the problem permanently, but not all mounts can be unmounted due
to "device or resource busy". I have to then run through manually and
kill the processes (almost always zsh as its the default shell) that
have a cwd of /home/username (ls -l /proc/[0-9]*/cwd | grep /home) or
have open files in the mounts.

Killing the processes is distasteful, but the only solution i've found
that works.

Once settled down I dont see any problems until the next time I mess
with the mounts. Restarting autofs or nfs also triggers this problem.

Can someone help me understand what is happening whent he mounts go
stale?

Thanks

Carl Gherardi

Apologies for crap to follow.

--

--
This email is confidential and intended solely for the use of the individual to whom it is addressed.  
Any views or opinions presented are solely those of the author and do not necessarily represent those of NAUTRONIX LTD.

If you are not the intended recipient, you have received this email in error and use, dissemination, forwarding, printing, or copying of 
this email is strictly prohibited.  If you have received this email in error please contact the sender.   

Although our computer systems use active virus protection software, and we take various measures to reduce the risk of viruses 
being transmitted in e-mail messages and attachments sent from this company, we cannot guarantee that such e-mail messages 
and attachments are free from viruses on receipt.  It is a condition of our using e-mail to correspond with you, that any and all liability 
on our part arising directly or indirectly out of any virus is excluded.  Please ensure that you run virus checking software on all e-mail 
messages and attachments before reading them.



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Brent M. Clements" <bclem@rice.edu>
Subject: Mounting any other os besides RHEW 3 doesn't work
Date: Tue, 6 Apr 2004 10:27:54 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.58.0404061018320.5509@is.rice.edu>
References: <1081197570.2641.133.camel@lade.trondhjem.org> <20040406092401.GA29906@suse.de>
 <1081260688.2846.30.camel@lade.trondhjem.org> <20040406142649.GF29906@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAsUZ-00067O-OR
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 08:27:59 -0700
Received: from is.rice.edu ([128.42.42.24])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BAsUZ-0007z0-G5
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 08:27:59 -0700
Received: from localhost (localhost [127.0.0.1])
	by localhost.is.rice.edu (Postfix) with ESMTP id D20B641947
	for <nfs@lists.sourceforge.net>; Tue,  6 Apr 2004 10:27:58 -0500 (CDT)
Received: from is.rice.edu ([127.0.0.1])
 by localhost (it.is.rice.edu [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 20605-06 for <nfs@lists.sourceforge.net>;
 Tue,  6 Apr 2004 10:27:56 -0500 (CDT)
Received: from localhost (localhost [127.0.0.1])
	by is.rice.edu (Postfix) with ESMTP id E978A4DC94
	for <nfs@lists.sourceforge.net>; Tue,  6 Apr 2004 10:27:55 -0500 (CDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040406142649.GF29906@suse.de>
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

We are stuck on a problem that no one seems to be able to answer, even
RedHat.

We noticed this problem when we tried deploying RHEW 3 Update 1 in a
production environment.

The problem can be reproduced in the following test environment:

1 HPUX 11.22 NFS Server
1 RHAW 2.1 IA64 System
2 RHEW 3 Update 1 IA64 Systems.

All systems are setup with no firewall settings.


Here are the scenarios:

Scenario 1:

The RHAW 2.1 system can properly mount and access the HPUX NFS system

Scenario 2:

The RHEW 3 system can properly mount the HPUX system but when you try to
do any access on the mounted nfs share, it hangs and the messages file on
the client state that the NFS server doesn't. We have noticed that the
client DOES get the nfs filehandle.

Scenario 3:

The RHEW 3 System can properly mount the RHAW 2.1(setup as an nfs server)
but when you try to do any access on the mounted nfs share, it hangs and
the messages file on the client states that the NFS server doesn't
respond. We have noticed that the client DOES get the nfs filehandle.

Scenario 4:
The RHEW 3 system can properly mount and access the other RHEW 3(setup as
an nfs server)


This is extremely wierd. it appears that the only thing that a RHEW 3
update 1 system can mount is another RHEW 3 update 1 system.


We have looked it over and every time we mount other types of nfs servers,
we receive a file handle but it looks like it fails in the data
connection.

Any help would be appreciated. We have submitted a bug report to RedHat
concerning this, but have not received any updates in a long time.

Thanks,

Brent Clements
Linux Technology Specialist
Information Technology
Rice University




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

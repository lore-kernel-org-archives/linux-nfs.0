From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: info for debugging failed lock recovery
Date: Fri, 28 Jan 2005 08:10:18 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501280808420.7869@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuXlq-0003Ck-TL
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 07:10:50 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuXlQ-0007zs-7R
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 07:10:50 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id j0SFAI3l020272
	for <nfs@lists.sourceforge.net>; Fri, 28 Jan 2005 08:10:18 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id j0SFAI3Q020268
	for <nfs@lists.sourceforge.net>; Fri, 28 Jan 2005 08:10:18 -0700
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

all-

i've been out sick all week but am about to dig back into our failing lockd
recovery issues.  if you recall we have this issue

   ~ client > get_and_hold_lock

   ~ server > cat /proc/locks      # shows correct lock pid

   ~ client > reboot

   ~ client > get_and_hold_lock    # fails!

   ~ server > cat /proc/locks      # shows old lock pid (before reboot) still 
there!

our clients AND servers are multihomed and each has iptables running.  we have
opened ALL traffic between client and server in the firewalls - NOTHING is
blocked.  still no go.  we're still seeing lots of SM_UNMON errors in var
messages and i'm suspicious these are related to some multi-homed issues
that's contributing to our failing lock recovery - but this is an un-educated
hunch.

at this point were are talking about starting a tcpdump in the nfslock script
so we can see what's going on during boot/lock-recovery.  my question is

   - what should i expect to see?  eg.  what exactly should the client be doing
     to recover it's locks?  which messages - which ports - etc.  i'm after a
     high level description here.  if there is anywhere i can read about this
     please let me know.

   - any other tips (someone has suggested using ethereal) to determine the
     problem?

sorry to drag this through the mud but our system is too fragile without
proper lock recovery to ignore and, unfortunately i'm not versed in debugging
these sorts of things.


kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

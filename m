From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: rpc.statd -n
Date: Wed, 2 Feb 2005 11:41:52 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502021127170.8434@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwPRq-0001mL-RH
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 10:41:54 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CwPRp-00045b-Rh
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 10:41:54 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id j12IfqiZ002688
	for <nfs@lists.sourceforge.net>; Wed, 2 Feb 2005 11:41:52 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id j12IfqSE002684
	for <nfs@lists.sourceforge.net>; Wed, 2 Feb 2005 11:41:52 -0700
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


i have a question regarding rpc.statd and it's reporting of hostname.  in the
case of a multi-homed client, say one running nfs on the

   client.b.domain

interface.  rpc.statd must be forced to report itself as 'client.b.domain'
lest lockd recovery fail when it reports client.domain.  this is all well and
good - but what if you have nfs running on more than one interface, like the
case of home dirs on front-door and file-server on back-door?  now what can
you do?  if you specify the hostname for rpc.statd you'll break lock recovery
on one or the other filesystem right?

i'm thinking that rpc.statd needs to be able to report as a user specified
name for each mounted filesystem - eg. a mount option.  if this were done
fstab could look something like

   moby.b:/raid/array0/part1/export on /dmsp/moby-0-1 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54,hostname=client.b.domain)
   moby:/raid/array0/part2/export on /home type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54,hostname=client.domain)

of course, there is already the 'mounthost' option - if all mounted
filesystems specified this as `uname -n` whould this make lock recovery work
for all interfaces?

obviously i know very little about this but am wondering what the best way to
make lock recovery work for mutil-homed clients mounting filesystems on > 1
interface.

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

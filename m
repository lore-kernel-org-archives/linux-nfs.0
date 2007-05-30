From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Subject: Stale NFS handles on LVM2
Date: Wed, 30 May 2007 09:07:10 +0200
Message-ID: <465D229E.5080809@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, linux-lvm@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtIHA-0007B7-Kl
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 00:07:20 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HtIHC-0003FR-Af
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 00:07:23 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I'm not sure if this is a NFS or LVM issue, so I cross-post this.
We get stale NFS handles on a LVM2 volume in the following scenario:

- The NFS server is running SLES10/kernel 2.6.16, but it happens
  with 2.6.21, too

- the server has /dev/sda, a built-in SCSI disk, with
  /dev/sda7 a LVM2 volume, say "exportlvm"

- due to module order in the initrd sda is always sda

- exportlvm is exported to the NFS clients

- the server has 4 fibre-channel raids connected, those have
  several partitions and two of the raids have LVM2 filesystems.

- the server doesn't mount or export any of the FC filesystems

Now, when we shutdown the fc port of the server or remove the fc cable, so 
that all the fc filesystems disappear, and then reboot the server,
the NFS client gets stale NFS handles on the "exportlvm". When we reboot
the client and then reconnect the FC cable or port and reboot the server
again, the stale NFS handles show up again.

When we change /dev/sda7 from a LVM2 to a normal fs, there are no stale 
NFS handles when rebooting the server in this way. 

Looks like rebooting the server after dis-/connecting the FC raids with
their LVMs somehow changes sth. on the LVM2 on /dev/sda7, like the minor
numbers etc. Is that possible? Is it a bug? Indeed the "exportlvm" is 
the last in the list when calling "vgscan" with the FC raids connected.

Is there a way I can ensure that things like minor numbers (or whatever
could cause these stales) are persistent on the "exportlvm"?

cu,
Frank
-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

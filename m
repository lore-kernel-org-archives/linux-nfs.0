From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: Stale NFS handles on LVM2
Date: Wed, 30 May 2007 10:23:12 +0200
Message-ID: <20070530082312.GA11045@janus>
References: <465D229E.5080809@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-lvm@redhat.com
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtJSc-0003NO-Qy
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 01:23:25 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HtJSe-00085e-HL
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 01:23:17 -0700
In-Reply-To: <465D229E.5080809@bio.ifi.lmu.de>
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

On Wed, May 30, 2007 at 09:07:10AM +0200, Frank Steiner wrote:
> Hi,
> 
> I'm not sure if this is a NFS or LVM issue, so I cross-post this.
> We get stale NFS handles on a LVM2 volume in the following scenario:
> 
> - The NFS server is running SLES10/kernel 2.6.16, but it happens
>   with 2.6.21, too
> 
> - the server has /dev/sda, a built-in SCSI disk, with
>   /dev/sda7 a LVM2 volume, say "exportlvm"
> 
> - due to module order in the initrd sda is always sda
> 
> - exportlvm is exported to the NFS clients
> 
> - the server has 4 fibre-channel raids connected, those have
>   several partitions and two of the raids have LVM2 filesystems.
> 
> - the server doesn't mount or export any of the FC filesystems
> 
> Now, when we shutdown the fc port of the server or remove the fc cable, so 
> that all the fc filesystems disappear, and then reboot the server,
> the NFS client gets stale NFS handles on the "exportlvm". When we reboot
> the client and then reconnect the FC cable or port and reboot the server
> again, the stale NFS handles show up again.
> 
> When we change /dev/sda7 from a LVM2 to a normal fs, there are no stale 
> NFS handles when rebooting the server in this way. 
> 
> Looks like rebooting the server after dis-/connecting the FC raids with
> their LVMs somehow changes sth. on the LVM2 on /dev/sda7, like the minor
> numbers etc. Is that possible? Is it a bug?

This is the behavior I would expect and is not a bug. Major/minor numbers
depend on the initialization order and number of block level devices
finally available for mounting the filesystems (disks/partitions/logical
volumes, etc). When pulling a disk or (in your case) volume in the middle
some numbers may shift and that affects the filehandles.

Use the fsid= option in /etc/exports to avoid this problem (clients need
to remount because this changes filehandles again).

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

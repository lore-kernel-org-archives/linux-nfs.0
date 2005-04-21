From: Kenneth Sumrall <ksumrall@pacbell.net>
Subject: NFS server hang, looking for suggestions
Date: Wed, 20 Apr 2005 22:10:36 -0700
Message-ID: <426735CC.9020900@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOTxa-00083j-4u
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 22:10:42 -0700
Received: from gateway-1237.mvista.com ([12.44.186.158] helo=av.mvista.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DOTxW-0006rN-HJ
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 22:10:42 -0700
Received: from pacbell.net (av [127.0.0.1])
	by av.mvista.com (8.9.3/8.9.3) with ESMTP id WAA04505
	for <nfs@lists.sourceforge.net>; Wed, 20 Apr 2005 22:10:36 -0700
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

At work, we have a very large (5.6 Tb) SCSI raid unit, which is formatted
as 1 XFS filesystem.  It is connected to a SuperMicro 6012P-6 dual CPU
Pentium-4 server.  The server is running on Suse 9.2, but we've upgraded
the kernel from the 2.6.8 that shipped with it to 2.6.11.7 from kernel.org.
The server exports the XFS filesystem using the kernel NFSD Version 3.

The machine has recently been hanging on a regular basis.  We think it's
related to NFS as the hangs often occur during a time in our nightly builds
when a bunch of machines are all writing data to the server at the same time.
However, sometimes the hangs occur when the write load is not as heavy.

The things we've tried are:
   Swap the server box with a spare.  Just to make sure it's not a hardware
   problem.

   Tried booting with "nosmp noapic" in case SMP was causing us problems.

   Update to 2.6.11.7, because I read about a problem exporting XFS over NFS
   in 2.6.8.  One thing I'm not clear on, with the 2.6.8 XFS over NFS bug,
   could that cause XFS filesystem corruption.  Should I run xfs_check on
   my XFS filesystem?

   We recently re-cabled a bunch of the clients for this machine, and in the
   process, removed a choke point where 13 of our clients were funnelled through
   a 100 Mbs ethernet switch.  That could have caused major fragmentation issues,
   which I've read are a bad thing.  It's only been 1 day since we did that, so
   no data yet on if things are better.

Other things to note.  Because the RAID is so big, we are running XFS directly
on the raw disk device, not a partition.  The partition format seems to have
problems with sizes over 2 terabytes.  Of course, I had to turn on CONFIG_LBD
in order to access such a large block device.

The ethernet interface is an e1000 gigabit interface.  It plugs directly into
our main Foundry ethernet switch.  The clients all have 100 Mbit interfaces, but
there's a bunch of them.

Also, the RAID uses a sector size of 2048 bytes, not the typical 512 bytes.
The SCSI controller in the server is an Adaptec Ultra160 chip, and we're using
the aic7xxx driver.

Does anyone have any suggestions on how to further diagnose our problem?  I've
not used magic sysrq before, but I'm thinking maybe trying to dump a list of
current tasks, and the registers might be useful to see if it hangs in the
same place everytime.  Or I could apply the KGDB patch, and try using that.

Does anyone have any other ideas on how to diagnose this?  Any known problems
I'm not aware of?  I'd really like to make this server rock solid.

Thanks.

Ken Sumrall
ksumrall@pacbell.net



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Kresimir Kukulj <madmax@iskon.hr>
Subject: Re: NFS problems (kernel locks up)
Date: Fri, 21 Mar 2003 23:57:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030321225751.GB22934@max.zg.iskon.hr>
References: <20030319182241.GA9216@max.zg.iskon.hr> <200303212049.59152.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iskon.hr ([213.191.128.4])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18wVSu-0005v1-00
	for <nfs@lists.sourceforge.net>; Fri, 21 Mar 2003 14:58:20 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200303212049.59152.bernd-schubert@web.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Quoting Bernd Schubert (bernd-schubert@web.de):
> > Some info about hardware:
> > Dell PowerApp 200 with 2 x Pentium III (Coppermine), each 1GHz.
> > 1Gb memory, with CONFIG_HIGHMEM4G=y.
> > eepro100 ethernet
> > ServerWorks chipset but nothing except CDROM is connected to it.
> > ICP Vortex Hardware RAID model GDT8523RZ
> > Driver for this (SCSI) controller is from 2.4.20 kernel (its pretty new).
> > 5 FUJITSU MAJ3364MC 34Gb drives in RAID5 (4+hotfix).
> > Filesystem is ext3 with journal=ordered.
> >
> 
> We have a rather similar machine (well, without the raid and not from Dell) 
> and with 2GB. Actually we had some trouble with the serverworks chipset and 
> the memory.
> The lockups you are describing are probably not nfs related, but due to your 
> hardware. Try to update your bios, disable mtrr, agp, similar speed 
> optimizing things in your kernel configuration. 
> Run memtest86 (the full test), even if you have ECC.
> If all of this still doesn't help, try to disable dual-cpu support.
> As much as I know ext3 make more problems with nfs than reiserfs does, but 
> this shouldn't cause the lockups

Uh, sorry to follow up again, but forgot to ask.
Could you elaborate a bit what problems ext3 has with NFS?
Have you tried XFS and what are your experiences using it with NFS?
I hope this in not to off-topic for this list.

-- 
Kresimir Kukulj                      madmax@iskon.hr
+--------------------------------------------------+
Old PC's never die. They just become Unix terminals.


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

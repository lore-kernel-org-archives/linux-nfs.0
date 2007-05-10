From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: nfs locking up system: rpc-srv/tcp: nfsd: got error -104
Date: Thu, 10 May 2007 11:43:50 -0400
Message-ID: <20070510154346.GA26131@salusa.poochiereds.net>
References: <46433A0E.6080200@panix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: For users of Fedora <fedora-list@redhat.com>,
	nfs@lists.sourceforge.net
To: Bob Kryger <bobk@panix.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HmAo3-0005jU-LJ
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 08:43:52 -0700
Received: from ms-smtp-05.southeast.rr.com ([24.25.9.104])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HmAo6-0005vq-2x
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 08:43:54 -0700
In-Reply-To: <46433A0E.6080200@panix.com>
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

On Thu, May 10, 2007 at 11:28:14AM -0400, Bob Kryger wrote:
> Can someone explain the error and possibly give me a hint as to how to 
> move forward...
> 
> Thanks
> Bob
> 
> Installed a new FC6 system:
> 
> [root@nfs3 log]# uname -a
> Linux nfs3 2.6.18-1.2798.fc6 #1 SMP Mon Oct 16 14:37:32 EDT 2006 i686 i686 i386 GNU/Linux
> 
> The system is not stable - it locks up after the following message 
> occurs (here are two occurances).
> 
> May  8 10:31:48 nfs3 kernel: rpc-srv/tcp: nfsd: got error -104 when sending 140 bytes - shutting down socket
> May  9 18:20:32 nfs3 kernel: rpc-srv/tcp: nfsd: got error -104 when sending 132 bytes - shutting down socket

$ grep 104 /usr/include/asm-generic/errno*
/usr/include/asm-generic/errno.h:#define        ECONNRESET      104     /* Connection reset by peer */

I'd suspect some sort of network issue or a problem on the other end of the
connection. Sniffing traffic on the wire while reproducing this might help to
confirm it and determine where RST packets are coming from.

> 
> It seems to happen every day or so, but the system is not yet in 
> production, so there is very little if and any traffic on it.  I had 
> originally though this had something to do with using 
> rsize=8192,wsize=8192 on a client, while testing, but wonder if that may 
> just have accelerated the issue, as it has now happened when  there is a 
> mount without such specs, and very little traffic (overnight).
> 
> There are no other error messages occurring with this one. (Is this even 
> a NFS error, or possibly portmapper?)
> 
> Hardware:
> 
> BIOS Information
>         Vendor: Phoenix Technologies LTD
>         Version: 6.00
>         Release Date: 10/30/2006
> 
> Base Board Information
>         Manufacturer: Supermicro
>         Product Name: PDSMi
> Processor Information
>         Socket Designation: LGA775/U1
>         Type: Central Processor
>         Family: <OUT OF SPEC>
>         Manufacturer: Intel
>         ID: 49 0F 00 00 FF FB EB BF
>         Version: Intel(R) Celeron(R) D CPU 2.80GHz
> 
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
> 
> QLogic Fibre Channel HBA Driver
> ACPI: PCI Interrupt 0000:00:1f.3[B] -> GSI 19 (level, low) -> IRQ 233
> ACPI: PCI Interrupt 0000:0a:01.0[A] -> GSI 24 (level, low) -> IRQ 58
> qla2xxx 0000:0a:01.0: Found an ISP2300, irq 58, iobase 0xf8882000
> qla2xxx 0000:0a:01.0: Configuring PCI space...
> qla2xxx 0000:0a:01.0: Configure NVRAM parameters...
> qla2xxx 0000:0a:01.0: Verifying loaded RISC code...
> qla2xxx 0000:0a:01.0: Allocated (412 KB) for firmware dump...
> qla2xxx 0000:0a:01.0: Waiting for LIP to complete...
> Floppy drive(s): fd0 is 1.44M
> FDC 0 is a post-1991 82077
> qla2xxx 0000:0a:01.0: LIP reset occured (f8f7).
> qla2xxx 0000:0a:01.0: LIP occured (f8f7).
> qla2xxx 0000:0a:01.0: LOOP UP detected (1 Gbps).
> qla2xxx 0000:0a:01.0: Topology - (Loop), Host Loop address 0x8
> scsi1 : qla2xxx
> qla2xxx 0000:0a:01.0:
>  QLogic Fibre Channel HBA Driver: 8.01.07-k1
>   QLogic QLA2310 -
>   ISP2300: PCI-X (66 MHz) @ 0000:0a:01.0 hdma-, host#=1, fw=3.03.20 IPX
> 
> There are 8 disks like this one on the Qlogic which are set up in an md 
> array and exported via NFS3
> 
> sd 1:0:0:0: Attached scsi disk sda
>   Vendor: SEAGATE   Model: ST1181677FC       Rev: 0001
>   Type:   Direct-Access                      ANSI SCSI revision: 03
> 
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

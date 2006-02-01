From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 07:46:25 +0100
Message-ID: <43E05941.20007@t-online.de>
References: <43E05031.2000107@t-online.de>	 <1138774519.7861.4.camel@lade.trondhjem.org>  <43E0567F.20004@t-online.de> <1138775744.7875.0.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4Bkq-00027H-4D
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 22:46:12 -0800
Received: from mailout02.sul.t-online.com ([194.25.134.17])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F4Bkp-0000KV-KJ
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 22:46:12 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138775744.7875.0.camel@lade.trondhjem.org>
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


>>AOpen i915GMm-HFS with Pentium M, linux kernel 2.6.15-git7
>>running a system that startet as SuSE 9.2. Nfs-utils are still
>>the original 1.0.6, grep -i nfs linuxbuild/.config gives
>>    
>>
>
>...and what kind of filesystem are you exporting?
>
>  
>

linux:/src/k6bv3p # dmesg | grep sda

[4294667.296000] Kernel command line: root=/dev/sda3 
video=intelfb:vram=8 vga=0x307
[   46.848978] SCSI device sda: 488397168 512-byte hdwr sectors (250059 MB)
[   46.850423] sda: Write Protect is off
[   46.851871] sda: Mode Sense: 00 3a 00 10
[   46.851884] SCSI device sda: drive cache: write back w/ FUA
[   46.853385] SCSI device sda: 488397168 512-byte hdwr sectors (250059 MB)
[   46.854868] sda: Write Protect is off
[   46.856330] sda: Mode Sense: 00 3a 00 10
[   46.856342] SCSI device sda: drive cache: write back w/ FUA
[   46.857821]  sda: sda1 sda2 sda3
[   46.869751] sd 0:0:0:0: Attached scsi disk sda
[   20.839566] ReiserFS: sda3: found reiserfs format "3.6" with standard 
journal
[   22.412053] ReiserFS: sda3: using ordered data mode
[   22.417920] ReiserFS: sda3: journal params: device sda3, size 8192, 
journal first block 18, max trans len 1024, max batch900, max commit age 
30, max trans age 30
[   22.419518] ReiserFS: sda3: checking transaction log (sda3)
[   22.440517] ReiserFS: sda3: Using r5 hash to sort names
[   24.597554] Adding 1052216k swap on /dev/sda1.  Priority:42 extents:1 
across:1052216k

(printk timestamp anomalities caused by cpu speed)

cu,
 Knut


cu,
 Knut


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

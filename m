From: Christopher Smith <csmith@nighthawkrad.net>
Subject: Re: Poor performance (especially writes)
Date: Fri, 08 Dec 2006 18:13:13 +1100
Message-ID: <45791089.7020804@nighthawkrad.net>
References: <45786A71.7080908@nighthawkrad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsZvS-0003Kh-A7
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 23:13:42 -0800
Received: from mail.syd.nighthawkrad.net ([203.166.121.124])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsZvS-00014D-0k
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 23:13:43 -0800
Received: from localhost (localhost [127.0.0.1])
	by mail.syd.nighthawkrad.net (Postfix) with ESMTP id 3A41310814A
	for <nfs@lists.sourceforge.net>; Fri,  8 Dec 2006 18:12:40 +1100 (EST)
Received: from mail.syd.nighthawkrad.net ([127.0.0.1])
	by localhost (mail.syd.nighthawkrad.net [127.0.0.1]) (amavisd-new,
	port 10024)
	with LMTP id cFGsOklwyfaC for <nfs@lists.sourceforge.net>;
	Fri,  8 Dec 2006 18:12:38 +1100 (EST)
Received: from [172.25.253.244] (unknown [172.25.253.244])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.syd.nighthawkrad.net (Postfix) with ESMTP id C5E60108145
	for <nfs@lists.sourceforge.net>; Fri,  8 Dec 2006 18:12:38 +1100 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <45786A71.7080908@nighthawkrad.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Christopher Smith wrote:
> (Apologies if this is a repost, but I haven't seen it appear four hours 
> later and there's no indication the list is moderated...)
> 
> Hello, all,
> 
> I am having some trouble extracting good (or even average) performance
> out of my NFS server, particular for writes, and was hoping to get some
> suggestions as to how to improve it.

After a day of experimentation, I believe I've nailed this down as being 
related to Dell's SAS 5/i disk controller.  A regular SATA drive using 
the onboard SATA controller in this machine shows about 10x the 
performance untarring the smaller image files over NFS.

So, it would appear to be some weird interaction between NFS and Dell's 
SAS 5/i disk controller (rebadged LSI device):

02:08.0 SCSI storage controller: LSI Logic / Symbios Logic SAS1068 PCI-X 
Fusion-MPT SAS (rev 01)
         Subsystem: Dell: Unknown device 1f09
         Flags: bus master, 66Mhz, medium devsel, latency 72, IRQ 169
         I/O ports at ec00 [disabled] [size=256]
         Memory at fe9fc000 (64-bit, non-prefetchable) [size=16K]
         Memory at fe9e0000 (64-bit, non-prefetchable) [size=64K]
         Expansion ROM at fea00000 [disabled] [size=1M]
         Capabilities: [50] Power Management version 2
         Capabilities: [98] Message Signalled Interrupts: 64bit+ 
Queue=0/0 Enable-
         Capabilities: [68] PCI-X non-bridge device.
         Capabilities: [b0] MSI-X: Enable- Mask- TabSize=1



I have duplicated this problem with RHEL installed and reported it to 
Red Hat.  Anyone else interested ?


-- 
Christopher Smith

Systems Administrator
Nighthawk Radiology Services
Level 11, Suite 1101
Grosvenor Place
225 George Street
Sydney NSW 2000
Australia

T:  612 - 8211 2300 (IP: x8163)
F:  612 - 8211 2333
M:  61  - 407 397 563
USA Toll free:  866 241 6635
E: csmith@nighthawkrad.net
I: www.nighthawkrad.net

CONFIDENTIALITY NOTICE:   This email, including any attachments, 
contains information from NightHawk Radiology Services, which may be 
confidential or privileged. The information is intended to be for the 
use of the individual or entity named above. If you are not the intended 
recipient, be aware that any disclosure, copying, distribution or use of 
the contents of this information is prohibited. If you have received 
this email in error, please notify NightHawk Radiology Services 
immediately by forwarding message to postmaster@nighthawkrad.net and 
destroy all electronic and hard copies of the communication, including 
attachments.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

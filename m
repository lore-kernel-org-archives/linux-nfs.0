From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 10:13:03 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210150951240.19850-100000@kenzo.iwr.uni-heidelberg.de>
References: <CFEAJJEGMGECBCJFLGDBAEGICFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Daniel Phillips <phillips@arcor.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181MpA-0005ZL-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 01:13:08 -0700
To: Eff Norwood <enorwood@effrem.com>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBAEGICFAA.enorwood@effrem.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Mon, 14 Oct 2002, Eff Norwood wrote:

> Also interesting is what UNKNOWN_KERNEL is. ???

Do you have any binary-only modules in the running kernel ?

> The server described above has 14 internal IDE disks configured as software
> Raid 5 and connected to the network with one Syskonnect copper gigabit card.

Please confirm: you have at least 7 IDE controllers. If so, how are the 
interrupts associated to them (look in /proc/interrupts) ? Are there 
shared interrupts ? Is the NIC sharing an interrupt line with at least one 
IDE controller ? I believe the answer to the last question might be yes, 
as this would explain why disk access is fast, but mixed disk+network 
access is slow; IDE drivers and NIC drivers don't mix well (see 
discussions over "max_interrupt_work" parameter for most network drivers).
However, NFS might not be a good network test in this case, maybe ftp - or 
anything TCP based - would have been better.

> I used 30 100 base-T connected clients all of which performed sequential
> writes to one large 1.3TB volume on the file server. They were mounted
> NFSv2, UDP, 8K r+w size for this run.

Err, you have a GE NIC in the server and FE NICs in the clients. Running 
NFS over UDP might not the best solution in this case; try NFS over TCP.

> I was able to achieve only 35MB/sec of sustained NFS write throughput.
> Local disk performance (e.g. dd file)  for sustained writes is *much*
> higher.

I don't know how you tested this, but disk head movement might influence 
the results a lot. For a single file (the "dd" case), the kernel will 
probably try to create a contiguous file, of course limited by the free 
regions of the disk; however, when writting to 30 files simultaneously, 
the kernel might have to wait for the disk to write in different regions 
for different files - I'm sure Daniel could explain this better than me - 
so that write speed is much reduced. I think that a better disk test would 
be to try to do all the 30 writes simultaneously on the server itself with 
"dd" or something similar, so that the network is not involved.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

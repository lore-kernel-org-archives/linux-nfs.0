From: "Lorn Kay" <lorn_kay@hotmail.com>
Subject: Re: NAS over NFS vs SAN
Date: Wed, 11 Jun 2003 17:02:47 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Law11-F33qNdCA1Z4zx0000bb98@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from law11-f33.law11.hotmail.com ([64.4.17.33] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Q8zw-0003KU-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Jun 2003 10:02:56 -0700
To: xinyuwu@hotmail.com, nfs@lists.sourceforge.net
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


We use NFS to a vendor-supplied NAS box for transaction-based production 
data and have suffered no data loss and no erronous (we think) locks. We use 
100BaseT Ethernet via a normal, switched network.

All access to the NAS is from Linux NFS clients using the same version of 
the kernel (we use NFS over TCP) and the same distro, etc. (This is kernel 
version 2.4.19 by the way.)

Based on this experience I would describe it as rock solid.

--K

_________________________________________________________________
The new MSN 8: smart spam protection and 2 months FREE*  
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

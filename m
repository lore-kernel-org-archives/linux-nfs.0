From: "Jeff L. Smith" <jeff@atheros.com>
Subject: Vaguely NFS related problem
Date: Wed, 11 Dec 2002 17:47:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DF7EA94.20108@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.atheros.com ([65.212.155.130] helo=atheros.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MIRO-0007KC-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 17:47:06 -0800
Received: from [10.10.10.91] (account jeff HELO atheros.com)
  by atheros.com (CommuniGate Pro SMTP 4.0.1)
  with ESMTP id 2380610 for nfs@lists.sourceforge.net; Wed, 11 Dec 2002 17:47:00 -0800
To: nfs@lists.sourceforge.net
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

We have been running a couple of machines (PIII with Mylex Extreme 2000 
SCSI RAID, RH7.3, 2.4.18 kernel, 64 nfsd's) which only act as NFS 
fileservers.  When either of these servers start getting busy, I start 
seeing a lot of the following messages:

Dec  8 15:27:58 localhost kernel: RPC: Unable to allocate resbuf from cache!

I does not seem to cause any problems (things keep running with no 
obvious corruption) but this surly cannot be good.  Is there something I 
need to tune or a FAQ I could review?

Jeff


-- 
Jeff Smith                                  Atheros Communications, Inc.
Hardware Manager                            529 Almanor Avenue
(408) 773-5257                              Sunnyvale, CA  94086



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

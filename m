From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Vaguely NFS related problem
Date: Thu, 12 Dec 2002 13:12:34 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15863.61586.150820.505519@notabene.cse.unsw.edu.au>
References: <3DF7EA94.20108@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MIq9-0002vS-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 18:12:42 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.234] == wireless-234.wireless.cse.unsw.EDU.AU)
	(for <jeff@atheros.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 12 Dec 2002 13:12:34 +1100
To: "Jeff L. Smith" <jeff@atheros.com>
In-Reply-To: message from Jeff L. Smith on Wednesday December 11
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

On Wednesday December 11, jeff@atheros.com wrote:
> We have been running a couple of machines (PIII with Mylex Extreme 2000 
> SCSI RAID, RH7.3, 2.4.18 kernel, 64 nfsd's) which only act as NFS 
> fileservers.  When either of these servers start getting busy, I start 
> seeing a lot of the following messages:
> 
> Dec  8 15:27:58 localhost kernel: RPC: Unable to allocate resbuf from cache!

This message is not part of any 'vanilla' release kernel.  It must be
a redhat-special.  Ask redhat.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

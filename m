From: Chip Salzenberg <chip@pobox.com>
Subject: Re: NFS/NAT(MASQUERADING) trouble
Date: Sat, 21 Sep 2002 22:11:08 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020922021108.GD30397@perlsupport.com>
References: <Pine.HPX.4.33.0209181349480.28921-100000@hpbai1.ifh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Steven Lowette <lowette@hep.iihe.ac.be>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17tDa6-0002WE-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Sep 2002 13:43:54 -0700
Received: from pipe.cepstral.com ([66.93.62.146] helo=tytlal)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 17tDa3-0002su-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Sep 2002 13:43:51 -0700
To: Peter Niessen <niessen@ifh.de>
In-Reply-To: <Pine.HPX.4.33.0209181349480.28921-100000@hpbai1.ifh.de>
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

According to Peter Niessen:
> the master machine, and only this one, gets into trouble.
> First, it will loose the disk which the clients write to (1000 files
> of ~2MB size, roughly ten of them within a minute in 10 minute
> intervals + a ~kB logfile and an empty status file), then other disks
> on the server. The clients are still able to see the server through
> the master, NFS as well as NIS.

What do you mean by the 'master' machine "losing" the disks?
-- 
Chip Salzenberg         - a.k.a.  -        <chip@pobox.com>
         "It furthers one to have somewhere to go."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

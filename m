From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: read-error on utmp file
Date: Mon, 13 Sep 2004 14:02:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41458C55.4020906@bio.ifi.lmu.de>
References: <41383991.1020108@bio.ifi.lmu.de>	 <1094230320.8196.32.camel@lade.trondhjem.org>	 <413C0F25.9010206@bio.ifi.lmu.de> <1094490287.8342.69.camel@lade.trondhjem.org> <413D5883.1080509@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C6pXX-0000Kl-Ui
	for nfs@lists.sourceforge.net; Mon, 13 Sep 2004 05:02:35 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C6pXX-0007KZ-Am
	for nfs@lists.sourceforge.net; Mon, 13 Sep 2004 05:02:35 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <413D5883.1080509@bio.ifi.lmu.de>
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

Hi,

I don't mean to get on anybodies nerves, so please don't get mad if I
ask again :-)

I still consider it a bug if of two concurrent read processes on an utmp file
(performed on the same nfs client) one fails with I/O error. It's not
a big thing, I just would like to know if it is worth changing my ckconfig
algorithms or if this bug is likely to disappear.

So any answer out of the set

- we don't consider this a bug
- we consider it a bug but can't care about it at the moment
- we are working on it

would be helpful :-) Just that I can decide what to do...

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

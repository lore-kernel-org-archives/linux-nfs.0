From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Fri, 10 Sep 2004 09:33:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <414158BD.4060802@bio.ifi.lmu.de>
References: <413FF4EB.2070607@bio.ifi.lmu.de> <1094741919.7972.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5tOR-0000Qr-2T
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 14:57:19 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5fxG-0008P4-B4
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 00:36:29 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094741919.7972.5.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

> Yep. We forgot to add the stub to Linux 2.6.x. Please confirm that the
> following patch fixes the problem for you.

Yes, with that patch it works fine and sendmail stops complaining.

Thanks a lot!
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

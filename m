From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Thu, 09 Sep 2004 14:25:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094754327.7972.19.camel@lade.trondhjem.org>
References: <413FF4EB.2070607@bio.ifi.lmu.de>
	 <1094741919.7972.5.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0409091153420.17332@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5Tc7-0004aW-5O
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 11:25:43 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5Tc5-0002sd-Bf
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 11:25:42 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0409091153420.17332@harp.ngdc.noaa.gov>
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

P=E5 to , 09/09/2004 klokka 13:54, skreiv Ara.T.Howard:
> will fsync'ing a directory have any affect on the client inode cache for =
that
> dir?  eg. will it invalidate that cache?

No. It should be a no-op.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Mon, 6 Dec 2004 11:16:57 +1100
Message-ID: <16819.42233.176348.675235@cse.unsw.edu.au>
References: <16815.63554.437489.308079@cse.unsw.edu.au>
	<OF5EAC57B5.E871608D-ON08256F5F.00634442-08256F5F.00638979@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb6Yx-0005L9-FO
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:17:11 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cb6Yw-0005cu-Lq
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:17:11 -0800
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: message from Bruce Allan on Friday December 3
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

On Friday December 3, bruce.allan@us.ibm.com wrote:
> Doesn't compile (missing event.h and nfsidmap.h).
> 
> gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include 
> -I/usr/include -Wall  -pipe  -DVERSION="\"nfs-utils 1.0.7-pre1\"" 
> -DNFS3_SUPPORTED -M atomicio.c cfg.c idmapd.c setproctitle.c strlcat.c 
> strlcpy.c > .depend
> idmapd.c:48:19: event.h: No such file or directory
> idmapd.c:61:22: nfsidmap.h: No such file or directory
> 

Yes........

It works better with 
    ./configure --disable-gss --disable-nfsv4

Bruce Fields would really rather distros compiled it with nfsv4
support enabled and so it made that the default.  However that
requires an extra package (or two?) which aren't commonly installed.

Bruce should be back from leave in a day or two so I might leave him
to argue further for keeping --enable-nfsv4 as the default (or to cave
it and let it be changed :-))

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

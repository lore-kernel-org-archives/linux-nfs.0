From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sun, 15 May 2005 08:54:51 +0200
Message-ID: <20050515065451.GA1037@fox>
References: <20050508132127.GA1744@fox> <1115560765.11308.6.camel@lade.trondhjem.org> <20050508143754.GA492@fox> <1115635107.24625.0.camel@lade.trondhjem.org> <20050509141339.GA3216@fox> <1115821422.13483.0.camel@lade.trondhjem.org> <20050514223904.GA580@fox> <1116113888.14297.27.camel@lade.trondhjem.org> <20050515062103.GA482@fox> <1116139197.12153.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DXD1k-00020w-Ve
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 23:55:04 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DXD1k-0005gY-7f
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 23:55:04 -0700
Received: from mail-mx1.uio.no ([129.240.10.29])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DXD1f-0004O4-QZ
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 08:54:59 +0200
Received: from 115.80-203-46.nextgentel.com ([80.203.46.115] helo=fox.venod.com)
	by mail-mx1.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DXD1d-0002zx-BX
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 08:54:57 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1116139197.12153.3.camel@lade.trondhjem.org>
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

Trond,

I actually managed to fix the hang with a third oplock option in
smb.conf that I missed before:  'oplocks = no'.  The last time, I
tried toggling fake oplocks and kernel oplocks, but neither of those
made any difference.  The plain 'oplocks' parameter did though!
I've been running my test program for almost 25 minutes, and still
no hang.

Thanks for your persistence in tracking this down.  I'll have 
oplocks disabled for now.

> I suspect there were hanging locks. Some of those lease code changes
> look pretty suspicious, so I think I want to have a chat with Andy & co
> as soon as I get back to Michigan.

So this is, after all, a bug in NFS?  Strange that it hasn't hit
more people.  Searching for similar problems on Google Groups turned
up nothing.

-- 
 Haakon


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

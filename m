From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 01 Jun 2005 21:56:09 -0400
Message-ID: <1117677369.10822.52.camel@lade.trondhjem.org>
References: <20050602013816.79953.qmail@web30707.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddewb-00038K-Q0
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 18:56:25 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Ddewa-0002e4-2E
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 18:56:25 -0700
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20050602013816.79953.qmail@web30707.mail.mud.yahoo.com>
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

on den 01.06.2005 Klokka 18:38 (-0700) skreiv Shantanu Goel:
> Hi Trond,
> 
> The current NFS client can cause a program to stall
> for long periods of time because it flushes all dirty
> pages at once.  The attached patch addresses this by
> only writing back the amount requested by the VM
> layer.  It also reduces the # commit requests by
> waiting for some writeback to complete before issuing
> a commit.  The patch also speeds up writebacks of
> mmap'ed data by accumulating dirty pages but sending
> commits earlier and omitting FLUSH_STABLE.

Hi Shantanu,

Do you have any figures on this subject? I'd very much like to see how
this changes the figures for both the throughput and the latency. We
should look at both slow and fast networks (say 10Mbit, 100Mbit &
1GigE).

My other question is how it affects stability in the case of low memory
situations?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: Should NFS over loopback be over 10x slower compared to local fs
Date: Tue, 30 Mar 2004 11:04:29 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040330030429.GA26484@outblaze.com>
References: <20040329042504.GE14714@outblaze.com> <m3y8pkdoe5.fsf@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B89YH-0002cc-1T
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 19:04:33 -0800
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B89YG-0004la-Jl
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 19:04:32 -0800
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id 162DB37AFF
	for <nfs@lists.sourceforge.net>; Tue, 30 Mar 2004 03:04:32 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id 3EDBF16DD8B
	for <nfs@lists.sourceforge.net>; Tue, 30 Mar 2004 03:04:31 +0000 (GMT)
To: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>
In-Reply-To: <m3y8pkdoe5.fsf@merlin.emma.line.org>
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

> > Hi, I did a postmark run on a local ext3 filesystem (data=writeback) and
> > then compared it with the same filesystem mounted over loopback and then
> > over a 100Mbit switch, I see a dramatic slowdown with postmark numbers
> > of loopback NFS compared to local fs.
> 
> Depending on drive speed and write clustering, expect a significant
> slowdown I'm not sure 10x is OK, but it's certainly realistic.

I expected a slowdown, it's just that I felt that 10x was inappropiate.
Curious as to what others get with the same test run on different
OS/hardware

On FreeBSD 4.9-RELEASE on similar hardware, the slowdown is only half
compared to postmark over local softupdate enabled fs.

Also on 2.6.x, NFS over loopback wasn't that much faster than NFS over
100Mbit 

> There's an important difference between NFS and local file system, in
> semantics: Once the NFS server has acknowledged the _write_ request, the
> data is on disk. You don't get that sort of guarantee with a local file
> system unless you open with O_SYNC (and I wonder how many bugs
> "not-quite-synchronous" need to be shaken out WRT local file systems
> given the recent fsync() discussion).

Hmm, That's plausible. I did a tiobench run over a local ext3 fs
(data=writeback) and the same run over loopback NFS and the slowdown was
in sequential/random writes though sequential writes was much slower
than random writes



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Matthias Andree <ma+nfs@dt.e-technik.uni-dortmund.de>
Subject: Re: Should NFS over loopback be over 10x slower compared to local fs
Date: Mon, 5 Apr 2004 12:13:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040405101318.GA25203@merlin.emma.line.org>
References: <20040329042504.GE14714@outblaze.com> <m3y8pkdoe5.fsf@merlin.emma.line.org> <20040330030429.GA26484@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAR7L-00020a-KR
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 03:14:11 -0700
Received: from mail.dt.e-technik.uni-dortmund.de ([129.217.163.1] ident=[qt6NwavxBnHkTp7MwbmmgXz9SVjytFi/])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BAR7L-0007Gg-5V
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 03:14:11 -0700
Received: from m2a2.dyndns.org (krusty.dt.e-technik.uni-dortmund.de [129.217.163.1])
	by mail.dt.e-technik.uni-dortmund.de (Postfix) with ESMTP id 93922275A7
	for <nfs@lists.sourceforge.net>; Mon,  5 Apr 2004 12:13:22 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by merlin.emma.line.org (Postfix) with ESMTP id F1E46B78B7
	for <nfs@lists.sourceforge.net>; Mon,  5 Apr 2004 12:13:20 +0200 (CEST)
Received: from merlin.emma.line.org ([127.0.0.1])
 by localhost (m2a2.dyndns.org [127.0.0.1]) (amavisd-new, port 10024)
 with LMTP id 24918-02 for <nfs@lists.sourceforge.net>;
 Mon,  5 Apr 2004 12:13:18 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040330030429.GA26484@outblaze.com>
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

[re-sending after it hasn't been approved in almost a week]

On Tue, 30 Mar 2004, Yusuf Goolamabbas wrote:

> I expected a slowdown, it's just that I felt that 10x was inappropiate.
> Curious as to what others get with the same test run on different
> OS/hardware
> 
> On FreeBSD 4.9-RELEASE on similar hardware, the slowdown is only half
> compared to postmark over local softupdate enabled fs.

You are comparing apples to oranges. softupdate enabled file systems are
an allegedly "on-disk-image-always-consistent" version of saying
"asynchronous operation", but I've recently seen corruption so one or
another bug may still linger in softdep.

To compare apples to apples, you need to mount the UFS file with -o sync
on FreeBSD.

> Hmm, That's plausible. I did a tiobench run over a local ext3 fs
> (data=writeback) and the same run over loopback NFS and the slowdown was
> in sequential/random writes though sequential writes was much slower
> than random writes

If "slower" describes the ratio between local and NFS, then that's sane,
sequential writes don't suffer the head positioning latency.

-- 
Matthias Andree

Encrypt your mail: my GnuPG key ID is 0x052E7D95


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

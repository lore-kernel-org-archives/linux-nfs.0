From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] statfs fails with EOVERFLOW
Date: Tue, 23 Mar 2004 13:21:27 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040323132127.A322@infradead.org>
References: <20040323130513.GB30984@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5lqX-0002Tp-4d
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 05:21:33 -0800
Received: from phoenix.infradead.org ([213.86.99.234])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5lqW-0003S4-Lm
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 05:21:32 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040323130513.GB30984@suse.de>; from okir@suse.de on Tue, Mar 23, 2004 at 02:05:13PM +0100
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

On Tue, Mar 23, 2004 at 02:05:13PM +0100, Olaf Kirch wrote:
> I am currently dealing with a 2.6 bug report concerning statfs failing
> with EOVERFLOW. This happens on very large NFS file systems, and the
> problem is obviously that by default, we set s_blocksize to the wtmult
> value advertised by the server. If tbytes / wtmult exceeds 31 bits, statfs
> will fail with EOVERFLOW (on 2.4 it would silently produce crap values).

that's why we have statfs64 in 2.6, a program with the right LFS magic
and a recentish glibc should use if for you.



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

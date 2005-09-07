From: Greg Banks <gnb@sgi.com>
Subject: Re: Some code, and a question
Date: Wed, 7 Sep 2005 11:02:19 +1000
Message-ID: <20050907010219.GA14233@sgi.com>
References: <1126046397.3000.188.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ECoKg-0005ud-6n
	for nfs@lists.sourceforge.net; Tue, 06 Sep 2005 18:02:34 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ECoKe-0002is-0l
	for nfs@lists.sourceforge.net; Tue, 06 Sep 2005 18:02:34 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1126046397.3000.188.camel@seki.nac.uci.edu>
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

On Tue, Sep 06, 2005 at 03:39:57PM -0700, Dan Stromberg wrote:
> 
> OK, I know NFS isn't usually thought of as the fastest protocol under
> the sun,

Why would you think that?  NFSv3 can be very efficient at moving
bits from point A to point B.

> My question is, before diving into trying to determine this empirically,
> is there any theoretical reason why it would be better to have
> rsize==wsize,

>From a protocol point of view, no.

> or should it be better to just pick whatever rsize gives
> the best read performance and pick whatever wsize gives the best write
> performance, and not worry about if rsize!=wsize?

It will depend on the workload, but generally read and write throughput
will be better the larger the block size, up to a value beyond the
Linux kernel's ability to support.  I expect you will find your optimum
at rsize=wsize=32K.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [OOPS] 2.6.23.1 in NFS
Date: Fri, 09 Nov 2007 09:16:14 -0500
Message-ID: <1194617774.7459.30.camel@heimdal.trondhjem.org>
References: <20071109095558.GB29687@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Mark Hindley <mark@hindley.org.uk>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqUbp-0005W0-DT
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 06:13:24 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqUbr-00082e-LD
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 06:13:27 -0800
In-Reply-To: <20071109095558.GB29687@hindley.org.uk>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Fri, 2007-11-09 at 09:55 +0000, Mark Hindley wrote:
> I got this OOPS this morning on a K6. Sorry it is tainted by madwifi.
> ath5k doesn't (yet!) support my card. Box is K6 200, headless, used as
> firewall/router
> 
> It looks like the same codepath as http://lkml.org/lkml/2007/11/6/275
> but my kernel was definitely compiled on a local disk.

You are hitting the BUG_ON() in line 909, whereas Mathieu was hitting
something further up in the same routine.

However I agree that they look suspicious. Both look as if something is
corrupting the rpc_task structure. In your case, a debugging tag that is
only ever touched by the RPC code at the very start and very finish of
the call is being changed, which points at something like a
use-after-free issue.

Hmm... I note that you are both running with the SLUB allocator. Any
chance you can reproduce using SLAB (and with the SLAB debugging
enabled)?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

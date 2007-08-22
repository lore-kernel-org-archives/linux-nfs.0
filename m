From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Attribute timeout handling and wrapping
	u32	jiffies
Date: Wed, 22 Aug 2007 14:47:33 -0400
Message-ID: <20070822184733.GF20946@fieldses.org>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
	<20070727015900.GA3000@sleipnir.redhat.com>
	<20070731162503.GC2964@sleipnir.redhat.com>
	<1185911253.6700.52.camel@localhost>
	<20070822182547.GD2874@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INvEr-0006CX-91
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 11:47:33 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INvEu-0003iV-An
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 11:47:37 -0700
In-Reply-To: <20070822182547.GD2874@sleipnir.redhat.com>
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

On Wed, Aug 22, 2007 at 03:25:47PM -0300, Fabio Olive Leite wrote:
> Hi Trond,
> 
> On Tue, Jul 31, 2007 at 03:47:33PM -0400, Trond Myklebust wrote:
> > 
> > It looked good when I laster reviewed it, but I haven't yet tested
> > it myself. Please send me a reminder if you don't see it appear in
> > the next NFS_ALL release (which should be within a week).
> 
> It was commited to the nfs-2.6.git repo, but I haven't seen it get
> upstream yet. Were there any issues I could work on to speed up this
> commit?

Normally if it's not fairly serious (causing an oops, for example) it'll
wait for the next merge window (after the final 2.6.23 comes out,
probably next month some time).

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

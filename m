From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: [PATCH] Attribute timeout handling and wrapping u32
	jiffies
Date: Wed, 22 Aug 2007 15:25:47 -0300
Message-ID: <20070822182547.GD2874@sleipnir.redhat.com>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
	<20070727015900.GA3000@sleipnir.redhat.com>
	<20070731162503.GC2964@sleipnir.redhat.com>
	<1185911253.6700.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INuuA-00043L-On
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 11:26:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INuuD-0003so-Rm
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 11:26:15 -0700
In-Reply-To: <1185911253.6700.52.camel@localhost>
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

Hi Trond,

On Tue, Jul 31, 2007 at 03:47:33PM -0400, Trond Myklebust wrote:
> =

> It looked good when I laster reviewed it, but I haven't yet tested
> it myself. Please send me a reminder if you don't see it appear in
> the next NFS_ALL release (which should be within a week).

It was commited to the nfs-2.6.git repo, but I haven't seen it get
upstream yet. Were there any issues I could work on to speed up this
commit?

Thanks!
F=E1bio
-- =

ex sed lex awk yacc, e pluribus unix, amem

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

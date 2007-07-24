From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Status of mount.nfs
Date: Tue, 24 Jul 2007 13:51:59 -0400
Message-ID: <1185299519.6586.28.camel@localhost>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no>
	<1185141493.6577.14.camel@localhost>  <20070722220442.GA32331@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDOYE-0007uh-BK
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 10:52:02 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/9DugxLCa9FvTLJn1VD1VICKgvPPqzhwA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDOYH-0005Gs-P0
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 10:52:06 -0700
In-Reply-To: <20070722220442.GA32331@uio.no>
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

On Mon, 2007-07-23 at 00:04 +0200, Steinar H. Gunderson wrote:
> On Sun, Jul 22, 2007 at 05:58:13PM -0400, Trond Myklebust wrote:
> > The default _had_ to change to TCP because UDP is just too unreliable
> > for NFS running with large (> 8k) r/w sizes, or on nonhomogeneous
> > networks (mixed 10/100/1000Gbit), or with fast clients.
> 
> Are you saying it changed between util-linux mount and nfs-utils mount.nfs? I
> thought that change happened a lot earlier, and that this was something else.

The private versions of util-linux maintained by RedHat and SuSE (and
Debian?) transitioned earlier, but I don't believe we ever sent those
patches to the upstream maintainers of util-linux.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

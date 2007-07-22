From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Status of mount.nfs
Date: Mon, 23 Jul 2007 00:04:42 +0200
Message-ID: <20070722220442.GA32331@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no>
	<1185141493.6577.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ICjXl-0004We-9O
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 15:04:49 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ICjXl-00036B-5Y
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 15:04:50 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1ICjXe-0006m6-Ho
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 00:04:42 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1ICjXe-0008Pw-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jul 2007 00:04:42 +0200
In-Reply-To: <1185141493.6577.14.camel@localhost>
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

On Sun, Jul 22, 2007 at 05:58:13PM -0400, Trond Myklebust wrote:
> The default _had_ to change to TCP because UDP is just too unreliable
> for NFS running with large (> 8k) r/w sizes, or on nonhomogeneous
> networks (mixed 10/100/1000Gbit), or with fast clients.

Are you saying it changed between util-linux mount and nfs-utils mount.nfs? I
thought that change happened a lot earlier, and that this was something else.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

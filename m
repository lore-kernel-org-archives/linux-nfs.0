From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Status of mount.nfs
Date: Wed, 25 Jul 2007 01:41:19 +0200
Message-ID: <20070724234119.GA17540@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDU0H-00049g-HX
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 16:41:21 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDU0K-0003v6-4H
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 16:41:25 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1IDU0G-0004mi-IA
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 01:41:20 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1IDU0G-0004Zt-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 01:41:20 +0200
In-Reply-To: <20070715083114.GB4158@uio.no>
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

On Sun, Jul 15, 2007 at 10:31:14AM +0200, Steinar H. Gunderson wrote:
> Just a few experiences with this after a week or so with the new default in
> Debian:

Here's a new one: mount doesn't pass -s (--sloppy) on to mount.nfs. This
causes odd behavior when people give all sorts of weird options, especially
(it seems) to automount. I've asked the util-linux maintainer in Debian to
fix the bug (and probably send the patch upstream), but I guess you should be
aware of the issue until it's fixed.

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

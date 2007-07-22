From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Status of mount.nfs
Date: Sun, 22 Jul 2007 21:17:33 +0200
Message-ID: <20070722191733.GA31501@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ICgvy-0004rX-MI
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 12:17:39 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ICgw0-0007Rp-7D
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 12:17:42 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1ICgvu-0002io-AQ
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 21:17:34 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1ICgvu-0008Cd-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Jul 2007 21:17:34 +0200
In-Reply-To: <18075.17719.855332.259470@notabene.brown>
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

On Mon, Jul 16, 2007 at 08:15:19PM +1000, Neil Brown wrote:
> Hmmm.... That code looks a little odd.  If you say you want udp, it
> will still probe for tcp first.  That doesn't hurt as UDP and TCP
> always use the same port: 2049.  But it is still odd.  I wonder if it
> is needed at all.

It seems it broke for a more normal situation as well:

  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=433881

Giving the "udp" option helped the user, though, but I don't really see why
the behavior changed.

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

From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: bug : sm-notify path is hardcoded into statd
Date: Mon, 23 Jul 2007 22:27:38 +0200
Message-ID: <20070723202738.GA5235@uio.no>
References: <46A4D420.1040801@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ID4VJ-0003th-W5
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 13:27:42 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ID4VM-0007nQ-Hh
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 13:27:45 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1ID4VG-0000yK-CN
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 22:27:38 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1ID4VG-0001My-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jul 2007 22:27:38 +0200
In-Reply-To: <46A4D420.1040801@oxeva.fr>
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

On Mon, Jul 23, 2007 at 06:15:28PM +0200, Gabriel Barazer wrote:
> Just found another which happens when nfs utilities are not installed in 
> /usr/sbin (e.g. because it's installed in /sbin for a diskless setup), 
> statd can't properly call sm-notify because the path to sm-notify is 
> hardcoded at utils/statd/statd.c:226 (nfs-utils-1.1.0). To preserve 
> consistency with configure switch, we must instead replace it with the 
> sbindir variable. (I can't reliably do a patch because I don't know 
> enough how to deal with the autotools).

FWIW, in Debian we simply change it to /sbin. A proper patch upstream would
probably be preferable, though -- smaller delta from upstream to
distributions is always good.

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

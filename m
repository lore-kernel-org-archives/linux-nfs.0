From: "Tradebit Service" <info@tradebit.com>
Subject: RE: blocked remote subdirectories
Date: Thu, 8 Dec 2005 12:51:26 +0100
Message-ID: <E1EkKHC-0002aL-WD@mail.sourceforge.net>
References: <17303.49759.151786.204513@cse.unsw.edu.au>
Reply-To: <info@tradebit.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkKHF-0006LW-Kl
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 03:49:33 -0800
Received: from aibo.runbox.com ([193.71.199.94] helo=cujo.runbox.com)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EkKHC-0002aL-WD
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 03:49:33 -0800
Received: from [10.9.9.15] (helo=odie.runbox.com)
	by greyhound.runbox.com with esmtp (Exim 4.34)
	id 1EkKH9-0008PI-FP
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 12:49:27 +0100
Received: from [84.168.129.37] (helo=muelleimer)
	by odie.runbox.com with asmtp  (uid:433466 )  (Exim 4.34)
	id 1EkKH8-00062I-UH
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 12:49:27 +0100
To: <nfs@lists.sourceforge.net>
In-Reply-To: <17303.49759.151786.204513@cse.unsw.edu.au>
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

> Are you running a redhat kernel earlier than about April2005, 
> and ext3 as the filesystem, and directory indexing enabled on 
> the filesystem.
> If so, you have hit a known bug.
> Either turn off directory indexing (tune2fs) or upgrade your kernel.

hi neil,

did miss that mail earlier, so disregard my last.
thanks for the hint, I will do so!

Regards,
Ralf



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

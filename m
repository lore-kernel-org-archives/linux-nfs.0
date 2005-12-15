From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits
	during chown
Date: Thu, 15 Dec 2005 11:50:42 -0500
Message-ID: <1134665442.7944.3.camel@lade.trondhjem.org>
References: <20051215130939.GA8111@hmsreliant.homelinux.net>
	 <1134656087.7954.7.camel@lade.trondhjem.org>
	 <20051215144945.GA8376@hmsreliant.homelinux.net>
	 <1134658644.7954.13.camel@lade.trondhjem.org>
	 <20051215163834.GB8376@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmwJw-0004fJ-DA
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:51:08 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmwJu-0002sq-4A
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:51:08 -0800
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20051215163834.GB8376@hmsreliant.homelinux.net>
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

On Thu, 2005-12-15 at 11:38 -0500, Neil Horman wrote:

> Then this patch should work just as well (and save the overhead of both adding
> the extra getaddr call and the need to add a helper function to all the other
> supported file systems to kill the SUID bits that already happens in the VFS.

NACK. The filesystem should _not_ try to second-guess what the VFS
intends it to do.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

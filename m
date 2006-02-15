From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount in a changing network
Date: Wed, 15 Feb 2006 14:23:45 -0500
Message-ID: <1140031426.7888.28.camel@lade.trondhjem.org>
References: <200602151716.18601.strieder@informatik.uni-kl.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9SGC-0000FY-5S
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 11:24:20 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9SG6-0003Dm-Gs
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 11:24:20 -0800
To: Bernd Strieder <strieder@informatik.uni-kl.de>
In-Reply-To: <200602151716.18601.strieder@informatik.uni-kl.de>
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

On Wed, 2006-02-15 at 17:16 +0100, Bernd Strieder wrote:

> Attaching gdb to the process and setting a breakpoint on printf, 
> after calling ferror returning 1, it is clear that printf does not 
> output anything. errno has the value 116 ESTALE.
> 
> How can this happen, an existing file gets into deleted status on 
> the client, without anybody having issued an unlink or whatever? 
> Or do stale filehandles finally result in deleted?

See http://nfs.sourceforge.net/#faq_a10

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

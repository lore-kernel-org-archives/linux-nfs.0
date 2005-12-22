From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: segfault in mount with CITI patch
Date: Thu, 22 Dec 2005 18:08:30 -0500
Message-ID: <1135292911.3685.4.camel@lade.trondhjem.org>
References: <43AA01AA.3060705@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpZmC-0007Du-Lj
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 15:23:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EpZmB-0000jO-9c
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 15:23:12 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <43AA01AA.3060705@google.com>
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

On Wed, 2005-12-21 at 17:30 -0800, Vince Busam wrote:
> Is nfsvers=3,mountvers=2 even OK to do?  If not, mount should print an error instead of 
> segfault.

Do you mean that the kernel Oopses, or is it really just a userland
segfault. If the latter, we really don't care too much: mixing nfsvers=3
and mountvers=2 is just silly. Sure, we can put a check in util-linux,
but there is no security implication.

OTOH, an Oops will be a security problem.

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

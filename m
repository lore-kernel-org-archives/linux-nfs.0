From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 12 Dec 2005 14:18:57 -0500
Message-ID: <1134415137.7877.10.camel@lade.trondhjem.org>
References: <4382252E.4000602@google.com>
	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>
	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com>
	 <1132614431.8011.14.camel@lade.trondhjem.org> <438B4983.3030809@google.com>
	 <1133203961.27574.66.camel@lade.trondhjem.org>
	 <4394AB2E.1030809@google.com>  <439DC809.3020502@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EltCs-0007Dk-UJ
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 11:19:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EltCr-0001Sd-GO
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 11:19:30 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <439DC809.3020502@google.com>
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

On Mon, 2005-12-12 at 10:57 -0800, Vince Busam wrote:
> I applied this patch from 2.6.15-rc5, and got the following oops.  I really wish I could 
> reproduce this faster, but it still only happens over the weekend when my credentials have 
> expired.  Letting them expire during the week doesn't reproduce it.

Could you send us the contents of rpc_close_pipes() and
rpc_pipe_release()?

I cannot see how rpc_pipe_release can be calling __rpc_purge_upcall with
a null entry for rpci->ops: the inode->i_sem should be protecting it
from changing.

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

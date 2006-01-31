From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Auto-load RPC authentication kernel modules
	(client-side)
Date: Tue, 31 Jan 2006 08:04:20 -0500
Message-ID: <1138712660.8892.16.camel@lade.trondhjem.org>
References: <20060131101337.GF1462@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F3vBk-0002xG-3I
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 05:04:52 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F3vBh-00072I-OM
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 05:04:52 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060131101337.GF1462@suse.de>
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

On Tue, 2006-01-31 at 11:13 +0100, Olaf Kirch wrote:
> Summary: Auto-load RPC authentication kernel modules (client-side)
> 
> This patch adds a request_module call to rpcauth_create which will try
> to auto-load the kernel module for the requested authentication flavor.
> For kernels with modular sunrpc, this reduces the admin overhead for
> the user.

Looks good. Applied

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

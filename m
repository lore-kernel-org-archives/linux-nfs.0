From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Diskless boot problems
Date: Mon, 14 Nov 2005 10:32:03 -0500
Message-ID: <1131982323.8870.22.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0511141441390.11652@xpc20.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EbgJs-00037P-4u
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:32:32 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EbgJo-0007X1-U5
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:32:32 -0800
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.64.0511141441390.11652@xpc20.ast.cam.ac.uk>
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

On Mon, 2005-11-14 at 14:55 +0000, Jeremy Sanders wrote:
> We have a set of clients which boot over the network, and mount their root 
> file systems over NFS from a server. All systems run linux-2.6.9-22 
> (Scientific Linux 4.1, a RHEL clone).
> 
> Occasionally the system breaks. For some reason some of the clients 
> produce errors in the logs like:
> 
> portmap: server localhost not responding, timed out
> RPC: failed to contact portmap (errno -5).
> portmap: server localhost not responding, timed out
> RPC: failed to contact portmap (errno -5).
> portmap: server localhost not responding, timed out
> RPC: failed to contact portmap (errno -5).
> lockd_up: makesock failed, error=-5
> portmap: server localhost not responding, timed out
> RPC: failed to contact portmap (errno -5).
> lockd_up: no pid, 2 users??

So what is the portmap daemon doing when this happens? Is it running? Is
it dead? Is it hanging?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

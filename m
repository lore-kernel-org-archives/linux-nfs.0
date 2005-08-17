From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Hang in 2.6.11.11 NFSv3 client following NFSERR_JUKEBOX
Date: Wed, 17 Aug 2005 10:15:52 -0400
Message-ID: <1124288152.23245.31.camel@lade.trondhjem.org>
References: <20050817133257.GK13622@sentientmeat.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5OiL-0003wt-Gy
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 07:16:21 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5OiK-0004Ei-0Z
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 07:16:21 -0700
To: Richard Perrin <rcp@sentientmeat.ca>
In-Reply-To: <20050817133257.GK13622@sentientmeat.ca>
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

on den 17.08.2005 Klokka 09:32 (-0400) skreiv Richard Perrin:
> Summary:
> After receiving an ERR_JUKEBOX, client does not appear to resend request.
> - Script to reproduce enclosed.
> - Packet capture available at
>   http://sentientmeat.ca/~rcp/tmp/nfs_traffic.gz
> - Reproduceable via interaction with a Samba server having oplocks enabled.
> - Related to Haakon Riiser's message of 2005-05-08 to the NFS list
> (http://sourceforge.net/mailarchive/message.php?msg_id=11689791).
> 
> Please see attached script for the order of operations. The end result is
> that a process reading a file on the NFSv3 client machine will become
> hung, unresponsive to signals after it receives the JUKEBOX error that
> the server sends. ps(1) reveals the NFS reading process to be in
> uninterruptible sleep.

Have you tried with 2.6.13-pre6 or any of the other kernels that has the
"sunrpc_timer_restart" patch applied? 

see
http://client.linux-nfs.org/Linux-2.6.x/2.6.12/linux-2.6.12-01-sunrpc_timer_restart.dif

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

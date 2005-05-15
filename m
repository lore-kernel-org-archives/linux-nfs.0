From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sun, 15 May 2005 08:21:03 +0200
Message-ID: <20050515062103.GA482@fox>
References: <20050508113343.GA629@fox> <1115556864.11308.1.camel@lade.trondhjem.org> <20050508132127.GA1744@fox> <1115560765.11308.6.camel@lade.trondhjem.org> <20050508143754.GA492@fox> <1115635107.24625.0.camel@lade.trondhjem.org> <20050509141339.GA3216@fox> <1115821422.13483.0.camel@lade.trondhjem.org> <20050514223904.GA580@fox> <1116113888.14297.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DXCVV-0008Tq-On
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 23:21:45 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DXCV1-0008Dc-US
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 23:21:45 -0700
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DXCUw-0001UP-8X
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 08:21:10 +0200
Received: from 115.80-203-46.nextgentel.com ([80.203.46.115] helo=fox.venod.com)
	by mail-mx4.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DXCUt-0006VC-W6
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 08:21:08 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1116113888.14297.27.camel@lade.trondhjem.org>
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

Trond,

> Why didn't you try the NFSv3 RFC? 8-)
> 
>    NFS3ERR_JUKEBOX
>        The server initiated the request, but was not able to
>        complete it in a timely fashion. The client should wait
>        and then try the request with a new RPC transaction ID.
>        For example, this error should be returned from a server
>        that supports hierarchical storage and receives a request
>        to process a file that has been migrated. In this case,
>        the server should start the immigration process and
>        respond to client with this error.
> 
> In other words, this is an error used by the server to say "I'm busy,
> and cannot retrieve the data you want. Please try again later".
> 
> Are you absolutely sure that you managed to disable oplocks on the samba
> server? 'cos this is the error an NFS server will usually return when it
> is waiting for the samba server (or an NFSv4 server) to break the lease
> on a file so that it can be opened.

I did set 'kernel oplocks = no' globally and restarted Samba, but I
didn't look for locked files with smbstatus.  I'll try again and
investigate a little more this time.  In the meantime, here's what
smbstatus shows:

Locked files:
Pid    DenyMode   Access   R/W     Oplock           Name
--------------------------------------------------------
32475  DENY_NONE  0x20089  RDONLY  EXCLUSIVE+BATCH foo Sun May 15 08:13:23 2005

This lock goes on and off all the time, which probably explains why
this error doesn't happen every single time I try to open the file.
But why does ERR_JUKEBOX cause the client to hang?  This lock _is_
soon released, so shouldn't NFS wake up once that happens?

-- 
 Haakon


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

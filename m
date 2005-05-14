From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sat, 14 May 2005 16:38:08 -0700
Message-ID: <1116113888.14297.27.camel@lade.trondhjem.org>
References: <20050508113343.GA629@fox>
	 <1115556864.11308.1.camel@lade.trondhjem.org> <20050508132127.GA1744@fox>
	 <1115560765.11308.6.camel@lade.trondhjem.org> <20050508143754.GA492@fox>
	 <1115635107.24625.0.camel@lade.trondhjem.org> <20050509141339.GA3216@fox>
	 <1115821422.13483.0.camel@lade.trondhjem.org>  <20050514223904.GA580@fox>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DX6DI-0000sq-9y
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 16:38:32 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DX6DG-0005r1-OD
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 16:38:32 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DX6DA-0001Bp-Ia
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 01:38:24 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050514223904.GA580@fox>
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

su den 15.05.2005 Klokka 00:39 (+0200) skreiv Haakon Riiser:
> Frame 52 (186 bytes on wire, 186 bytes captured)
> Ethernet II, Src: 00:50:04:55:8c:44, Dst: 00:01:02:fa:af:5f
> Internet Protocol, Src Addr: 10.0.0.2 (10.0.0.2), Dst Addr: 10.0.0.4 (10.0.0.4)
> Transmission Control Protocol, Src Port: nfsd (2049), Dst Port: 799 (799), Seq: 6256, Ack: 2172, Len: 120
> Remote Procedure Call, Type:Reply XID:0x70cf1c9d
> Network File System, READ Reply  Error:Unknown error:10008
>     Program Version: 3
>     V3 Procedure: READ (6)
>     Status: ERR_JUKEBOX (10008)
>     file_attributes
> 
> No.     Time        Source                Destination           Protocol Info
>      53 8.059968    10.0.0.4              10.0.0.2              TCP      799 > nfsd [ACK] Seq=2172 Ack=6376 Win=17376 Len=0 TSV=4294774881 TSER=1928447303
> 
> Frame 53 (66 bytes on wire, 66 bytes captured)
> Ethernet II, Src: 00:01:02:fa:af:5f, Dst: 00:50:04:55:8c:44
> Internet Protocol, Src Addr: 10.0.0.4 (10.0.0.4), Dst Addr: 10.0.0.2 (10.0.0.2)
> Transmission Control Protocol, Src Port: 799 (799), Dst Port: nfsd (2049), Seq: 2172, Ack: 6376, Len: 0
> -------------------------------------------------------------------------------
> 
> As you can see in the above, I'm running NFS over TCP, but I have
> also tried UDP, and it still hangs.  Anyway, have you seen this
> before?  ERR_JUKEBOX (10008) has only three hits on Google, and all
> of them point to the patches to Ethereal that made it recognize this
> error. :-)

Why didn't you try the NFSv3 RFC? 8-)

   NFS3ERR_JUKEBOX
       The server initiated the request, but was not able to
       complete it in a timely fashion. The client should wait
       and then try the request with a new RPC transaction ID.
       For example, this error should be returned from a server
       that supports hierarchical storage and receives a request
       to process a file that has been migrated. In this case,
       the server should start the immigration process and
       respond to client with this error.

In other words, this is an error used by the server to say "I'm busy,
and cannot retrieve the data you want. Please try again later".

Are you absolutely sure that you managed to disable oplocks on the samba
server? 'cos this is the error an NFS server will usually return when it
is waiting for the samba server (or an NFSv4 server) to break the lease
on a file so that it can be opened.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

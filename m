From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sun, 15 May 2005 00:39:04 +0200
Message-ID: <20050514223904.GA580@fox>
References: <20050508113343.GA629@fox> <1115556864.11308.1.camel@lade.trondhjem.org> <20050508132127.GA1744@fox> <1115560765.11308.6.camel@lade.trondhjem.org> <20050508143754.GA492@fox> <1115635107.24625.0.camel@lade.trondhjem.org> <20050509141339.GA3216@fox> <1115821422.13483.0.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DX5Hz-00079y-6Z
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 15:39:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DX5Hx-0003QT-Kj
	for nfs@lists.sourceforge.net; Sat, 14 May 2005 15:39:19 -0700
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DX5Hr-00039F-KE
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 00:39:11 +0200
Received: from 115.80-203-46.nextgentel.com ([80.203.46.115] helo=fox.venod.com)
	by mail-mx4.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DX5Hp-0005H1-8E
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 00:39:09 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1115821422.13483.0.camel@lade.trondhjem.org>
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

>> Should I run tcpdump on the server or the client, or perhaps it
>> doesn't matter?
> 
> Please try on the client first.

Done.  I tcpdump'd all data (-s0) to file, and opened it up in
Ethereal to make some sense of it.  I think these packets are the
ones of interest to you:  (10.0.0.2 is the NFS server and 10.0.0.4
is the NFS client)

-------------------------------------------------------------------------------
No.     Time        Source                Destination           Protocol Info
     51 8.020185    10.0.0.4              10.0.0.2              NFS      V3 READ Call (Reply In 52), FH:0x2322d19a Offset:0 Len:4096

Frame 51 (190 bytes on wire, 190 bytes captured)
Ethernet II, Src: 00:01:02:fa:af:5f, Dst: 00:50:04:55:8c:44
Internet Protocol, Src Addr: 10.0.0.4 (10.0.0.4), Dst Addr: 10.0.0.2 (10.0.0.2)
Transmission Control Protocol, Src Port: 799 (799), Dst Port: nfsd (2049), Seq: 2048, Ack: 6256, Len: 124
Remote Procedure Call, Type:Call XID:0x70cf1c9d
Network File System, READ Call FH:0x2322d19a Offset:0 Len:4096
    Program Version: 3
    V3 Procedure: READ (6)
    file
    offset: 0
    count: 4096

No.     Time        Source                Destination           Protocol Info
     52 8.020731    10.0.0.2              10.0.0.4              NFS      V3 READ Reply (Call In 51) Error:Unknown error:10008

Frame 52 (186 bytes on wire, 186 bytes captured)
Ethernet II, Src: 00:50:04:55:8c:44, Dst: 00:01:02:fa:af:5f
Internet Protocol, Src Addr: 10.0.0.2 (10.0.0.2), Dst Addr: 10.0.0.4 (10.0.0.4)
Transmission Control Protocol, Src Port: nfsd (2049), Dst Port: 799 (799), Seq: 6256, Ack: 2172, Len: 120
Remote Procedure Call, Type:Reply XID:0x70cf1c9d
Network File System, READ Reply  Error:Unknown error:10008
    Program Version: 3
    V3 Procedure: READ (6)
    Status: ERR_JUKEBOX (10008)
    file_attributes

No.     Time        Source                Destination           Protocol Info
     53 8.059968    10.0.0.4              10.0.0.2              TCP      799 > nfsd [ACK] Seq=2172 Ack=6376 Win=17376 Len=0 TSV=4294774881 TSER=1928447303

Frame 53 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: 00:01:02:fa:af:5f, Dst: 00:50:04:55:8c:44
Internet Protocol, Src Addr: 10.0.0.4 (10.0.0.4), Dst Addr: 10.0.0.2 (10.0.0.2)
Transmission Control Protocol, Src Port: 799 (799), Dst Port: nfsd (2049), Seq: 2172, Ack: 6376, Len: 0
-------------------------------------------------------------------------------

As you can see in the above, I'm running NFS over TCP, but I have
also tried UDP, and it still hangs.  Anyway, have you seen this
before?  ERR_JUKEBOX (10008) has only three hits on Google, and all
of them point to the patches to Ethereal that made it recognize this
error. :-)

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

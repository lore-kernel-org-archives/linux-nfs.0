From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: "Server not responding" after periods of client inactivity
Date: Tue, 9 Aug 2005 21:06:34 +0200
Message-ID: <20050809190634.GA5779@fox.upc.no>
References: <20050714212514.GA23867@fox> <20050730131031.GA1668@fox> <1122732943.8248.13.camel@lade.trondhjem.org> <20050730143216.GA2339@fox> <1122735345.8248.28.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E2ZR8-00009x-4s
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 12:06:54 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E2ZR5-0000XB-PA
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 12:06:54 -0700
Received: from mail-mx2.uio.no ([129.240.10.30])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1E2ZQy-00053d-VT
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 21:06:45 +0200
Received: from cm-80.111.122.093.chello.no ([80.111.122.93] helo=fox.venod.com)
	by mail-mx2.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1E2ZQv-0004mz-N2
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 21:06:41 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1122735345.8248.28.camel@lade.trondhjem.org>
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

>> Source  Time  Packets
>> ------  ----  -------
>> client  0.00  V3 ACCESS Call, FH:0x02120000
>> client  0.10  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  0.31  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  0.71  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  1.53  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  3.16  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  6.42  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  7.12  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client  8.52  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> client 11.32  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
>> server 15.30  V3 ACCESS Reply
> 
> This is a different problem that has nothing to do with connecting. If
> the client can send RPC requests, then the connection has clearly been
> set up.
> 
> If I were you, I'd look into what "mountd" is up to on the server when
> this happens. The server will just silently drop packets if mountd is
> slow to authorise the client.

OK, I've been trying for some time to reproduce the bug while
stracing mountd on the server, but it seems impossible to do it.
If I do

  strace -p $(pidof rpc.mountd)

the bug never occurs.  If I try to start strace immediately after
the hang begins, strace doesn't attach until the hang is over.
That is, it takes approximately 15 seconds (the entire duration of
the hang) before the

  Process <PID> attached - interrupt to quit

message is displayed and anything else is printed by strace.  Does
this tell you anything?

-- 
 Haakon


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

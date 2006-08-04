From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Processes hanging, directory hanging
Date: Fri, 4 Aug 2006 13:51:15 -0300
Message-ID: <20060804135115.6fc33923@sup-ceu.wrk.terra.com.br>
References: <20060801103059.129bc1ac@sup-ceu.wrk.terra.com.br>
	<20060804113838.26ebeed2@sup-ceu.wrk.terra.com.br>
	<1154704193.4727.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, f.soto@terra.com.br
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G92tN-00021K-C9
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 09:51:21 -0700
Received: from burta.hst.terra.com.br ([200.176.10.199])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G92tN-0003Z0-5A
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 09:51:21 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1154704193.4727.11.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi.

On Fri, 04 Aug 2006 11:09:52 -0400, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> So you upgraded the server, and the clients started to hang. What
> makes you think this is a client problem?

No, I didn't upgrade the NFS server... I just upgraded the LMTP server,
which is the software that uses the NFS client on Linux... Sorry if I
wrote this in a confusing way.

I guess the problem is in NFS client because the directory just
"disappears" or "hangs" when trying to cd/ls it on that client. The
problem doesn't happen in any other client, and also, rebooting the
client solves the problem.

> Have you tried comparing 'nfsstat' output on the client and server to
> see if the server is processing the client requests. A tcpdump to see
> if the client is receiving server replies would be useful too.

Ok, I'll try and provide a tcpdump. Comparing "nfsstat" I guess it's
difficult, because on the server it still gets requests from the other
clients, and it would be difficult to me to isolate only from that
client... However, I'll try to get a tcpdump on the server too (the
servers are EMC storage, not Linux, but I can get them to run tcpdump
too).

> Also, check what software you upgraded on the server. If it was samba,
> and you have oplock support enabled, then the problem could be related
> to leases (IIRC there were a few kernel bugs w.r.t. leases that had to
> be fixed recently).

The software on the client is an LMTP server, it's developped in-house,
and it got a somewhat large upgrade for new features. I don't believe
the problem is related to locks (as in "flock" or "fcntl") because the
software uses Maildir which doesn't need locks. Anyway, I'll investigate
this issue about oplocks and leases with the developpers, to see if the
problem could be related to that.

Thank you very much!
Filipe Brandenburger

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

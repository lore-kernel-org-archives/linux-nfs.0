From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Update: NFS over a Win2k Server NAT Router with
	"DMZ":nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 15:06:54 -0400
Message-ID: <1146164814.8101.44.camel@lade.trondhjem.org>
References: <005401c66a19$2a6f6d30$0200a8c0@novastorm>
	 <000401c66a21$154a8c70$0200a8c0@novastorm>
	 <1146160972.8101.12.camel@lade.trondhjem.org>
	 <002601c66a2a$0be49be0$0200a8c0@novastorm>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZBpW-0005LS-JI
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 12:07:10 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FZBpU-0004Gq-Vd
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 12:07:10 -0700
To: Michael Lackner <thrawn@xin.at>
In-Reply-To: <002601c66a2a$0be49be0$0200a8c0@novastorm>
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

On Thu, 2006-04-27 at 20:40 +0200, Michael Lackner wrote:
> Hello.
> 
> Maybe that might help resolving the issue? I did some tcpdump on client
> and fileserver. As expected, after the nfs readdir, there is no response
> coming from the fileserver.
> 
> On the fileserver itself i found this:
> ===
> 20:23:57.283012 CLIENTBEHINDNAT.3938904570 > FILESERVER.nfs: 164 readdirplus [|nfs] (DF) (ttl 63, id 9683, len 192)
> 20:23:57.283241 FILESERVER > CLIENTBEHINDNAT: udp (frag 9306:268@2960) (ttl 64, len 288)
> 20:23:57.283245 FILESERVER > CLIENTBEHINDNAT: udp (frag 9306:1480@1480+) (ttl 64, len 1500)
> 20:23:57.283249 FILESERVER.nfs > CLIENTBEHINDNAT.3938904570: reply ok 1472 readdirplus POST: DIR 40711 ids 505/505 [|nfs] (frag 
> 9306:1480@0+) (ttl 64, len 1500)
> 20:23:57.284227 CLIENTBEHINDNAT > FILESERVER: icmp: CLIENTBEHINDNAT unreachable - need to frag (mtu 1500) (ttl 128, id 4037, len 56)
> ===
> 
> What's that ICMP doing there? I don't quite understand the meaning
> of that output, but it seems as if nfs is relying on that ICMP packets
> reaching their target to work? Or maybe i'm wrong and the router just
> drops the returning packages (thats what you meant?)

The ICMP message is telling the server that the fragments are not
reaching the client.

If you can't use TCP, then I suggest you try mounting using rsize=1024.
That means that the client will issue smaller read/readdir requests
which should normally pass through the firewall without requiring
fragmentation. You will see a significant performance penalty compared
to clients that are behind the firewall, though...

Cheers,
  Trond



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

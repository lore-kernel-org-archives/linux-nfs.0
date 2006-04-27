From: "Michael Lackner" <thrawn@xin.at>
Subject: Re: Update: NFS over a Win2k Server NAT Router with "DMZ":nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 20:40:24 +0200
Message-ID: <002601c66a2a$0be49be0$0200a8c0@novastorm>
References: <005401c66a19$2a6f6d30$0200a8c0@novastorm> <000401c66a21$154a8c70$0200a8c0@novastorm> <1146160972.8101.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZBPh-0002Is-7J
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:40:29 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FZBPh-0007EU-93
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:40:29 -0700
Received: from 83-64-254-60.bruck-mur.xdsl-line.inode.at ([83.64.254.60] helo=xin.at)
	by mail.sourceforge.net with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.44)
	id 1FZBPe-0003Xg-R2
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:40:29 -0700
Received: from novastorm by xin.at
	(MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50000005503.msg
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 20:40:16 +0200
To: <nfs@lists.sourceforge.net>
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

Hello.

Maybe that might help resolving the issue? I did some tcpdump on client
and fileserver. As expected, after the nfs readdir, there is no response
coming from the fileserver.

On the fileserver itself i found this:
===
20:23:57.283012 CLIENTBEHINDNAT.3938904570 > FILESERVER.nfs: 164 readdirplus [|nfs] (DF) (ttl 63, id 9683, len 192)
20:23:57.283241 FILESERVER > CLIENTBEHINDNAT: udp (frag 9306:268@2960) (ttl 64, len 288)
20:23:57.283245 FILESERVER > CLIENTBEHINDNAT: udp (frag 9306:1480@1480+) (ttl 64, len 1500)
20:23:57.283249 FILESERVER.nfs > CLIENTBEHINDNAT.3938904570: reply ok 1472 readdirplus POST: DIR 40711 ids 505/505 [|nfs] (frag 
9306:1480@0+) (ttl 64, len 1500)
20:23:57.284227 CLIENTBEHINDNAT > FILESERVER: icmp: CLIENTBEHINDNAT unreachable - need to frag (mtu 1500) (ttl 128, id 4037, len 56)
===

What's that ICMP doing there? I don't quite understand the meaning
of that output, but it seems as if nfs is relying on that ICMP packets
reaching their target to work? Or maybe i'm wrong and the router just
drops the returning packages (thats what you meant?)

> If TCP support has been compiled into the kernel, then it should be
> running, in which case 'rpcinfo -t <server> nfs' should confirm it.

rpcinfo -t <fileserver> nfs says:
==
rpcinfo: RPC: Program not registered
program 100003 is not available
==

However...

rpcinfo -p <fileserver> | grep nfs says:
==
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
==

(Server is definitly up, other machines from the same network segment
as the server are mounting and reading/writing ok.)

Thanks.

Best Regards
Michael Lackner
University of Leoben
Chair for Information Technology, IT Administration 




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

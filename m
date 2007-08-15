From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8891] New: in-kernel rpc generates
 broken RPCBPROC_GETVERSADDR v4 requests
Date: Wed, 15 Aug 2007 12:29:09 -0700
Message-ID: <20070815122909.c67c0db6.akpm@linux-foundation.org>
References: <bug-8891-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	speidel@ueberschuss.de
To: netdev@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILOYR-00071h-VO
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 12:29:20 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILOYV-0001CK-Tg
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 12:29:24 -0700
In-Reply-To: <bug-8891-10286@http.bugzilla.kernel.org/>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 15 Aug 2007 12:22:51 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8891
> 
>            Summary: in-kernel rpc generates broken RPCBPROC_GETVERSADDR v4
>                     requests
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: speidel@ueberschuss.de
> 
> 
> Most recent kernel where this bug did not occur: 2.6.20

Apparently a regression.

> Distribution: Fedora Core 6
> Hardware Environment: x86_64
> Software Environment: NFS
> Problem Description: When locking a file, an invalid RPCBPROC_GETVERSADDR
> procedure call is sent out
> 
> Steps to reproduce:
> on the NFS server, run: tcpdump -xX -pni eth0 -s0 port 111 and src host
> theNFSclient
> on a client running 2.6.22.1, run: flock -x /nfsmount/somefile ls
> tcpdump will show:
> 
> 17:10:01.290655 IP 141.2.15.141.34572 > 141.2.1.1.sunrpc: P 0:168(168) ack 1
> win 183 <nop,nop,timestamp 966695 115079499>
>         0x0000:  4500 00dc 53ad 4000 3f06 bcdc 8d02 0f8d  E...S.@.?.......
>                 0x0010:  8d02 0101 870c 006f cdcd 938d db00 c8a7 
> .......o........
>         0x0020:  8018 00b7 e59d 0000 0101 080a 000e c027  ...............'
>         0x0030:  06db f94b 8000 00a4 fd48 2a07 0000 0000  ...K.....H*.....
>         0x0040:  0000 0002 0001 86a0 0000 0004 0000 0009  ................
>         0x0050:  0000 0001 0000 0054 0000 03c6 0000 0007  .......T........
>         0x0060:  6572 6964 796b 6500 0000 0000 0000 0000  eridyke.........
>         0x0070:  0000 000e 0000 0000 0000 0001 0000 0002  ................
>         0x0080:  0000 0003 0000 0004 0000 0005 0000 0006  ................
>         0x0090:  0000 0007 0000 0007 0000 0009 0000 000a  ................
>         0x00a0:  0000 000c 0000 0014 0000 001c 0000 0000  ................
>         0x00b0:  0000 0000 0001 86b5 0000 0004 0000 0003  ................
>         0x00c0:  7463 7000 0000 0009 3134 312e 322e 312e  tcp.....141.2.1.
>         0x00d0:  3100 0000 0000 0004 7270 6362            1.......rpcb
> 
> Note the "141.2.1.1" in the output.
> 
> According to RFC 1833, you can read here the following fields:
> 
> RPCBPROC_GETVERSADDR version 4 procedure is being called
> r_prog == 0x000186b5 == 100021 == nfs.lockd
> r_vers == 4
> r_netid == (length 3) "tcp"
> r_addr == (length 9) "141.2.1.1"
> r_owner == (length 4) "rpcb"
> 
> This r_addr member is supposed to contain an universal address. Although I have
> no source for that, the RFC clearly says a service can listen to an address,
> and RPCBPROC_GETVERSADDR is supposed to return an universal address too. From
> this I can conclude that an universal address is supposed to contain the port
> number, and other operating systems are using the format
> a.b.c.d.PortHighByte.PortLowByte (like in FTP, but with . instead of ,). I
> interpret the RFC 1833 so that the port number of the rpcbind, that is, 111, is
> to be appended, so the correct value of r_addr would be "141.2.1.1.0.111". This
> matches other implementations.
> 
> Of course, all this does sound like nitpicking, and as the callee is not even
> supposed to look at the port number (this argument is only there so the callee
> can decide correctly which interface address to use for the response). However,
> this omission triggers an apparently unpatched denial of service vulnerability
> against HP-UX 11.11's rpcbind and causes it to quit with a core dump and a bus
> error. When using a correctly formed universal address, or the empty string,
> there is no crash of HP-UX's rpcbind.
> 
> And of course it is HP who has to fix the DoS bug - but Linux 2.6.22 triggers
> it by a RFC violation, which is a minor bug to be fixed on Linux's side. By the
> way, does anyone have the right contacts to HP to report this bug? I do not
> have a HP service contract any more, and the only other support place I found
> is their public forum, where I of course can only provide limited information
> about the bug (basically, the same I am posting here).
> 
> Maybe the bug is fixed in a more current kernel, I was only using Fedora's
> highly patched distribution kernel and compared it to the sources of the base
> version in the main tree, where I see the very same problem in the source code.
> So I do not think it was Fedora who caused the problem, and am assigning it to
> mainline.
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

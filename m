From: Filipe Brandenburger <branden@terra.com.br>
Subject: NFS in kernel 2.6 and Netapp: privileged ports problem
Date: Thu, 21 Jul 2005 10:19:50 -0300
Message-ID: <20050721100913.D93F.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dvazt-0005QO-4i
	for nfs@lists.sourceforge.net; Thu, 21 Jul 2005 06:21:57 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dvazr-0003Np-Gj
	for nfs@lists.sourceforge.net; Thu, 21 Jul 2005 06:21:57 -0700
Received: from paramonga.terra.com.br ([200.154.55.230])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1Dvazp-0005cA-WB
	for nfs@lists.sourceforge.net; Thu, 21 Jul 2005 06:21:55 -0700
Received: from moroto.terra.com.br (moroto.terra.com.br [200.176.10.5])
	by paramonga.terra.com.br (Postfix) with ESMTP id A37375E6FC9
	for <nfs@lists.sourceforge.net>; Thu, 21 Jul 2005 10:19:50 -0300 (BRT)
Received: from [200.176.1.176] (dsk17134-vm.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by moroto.terra.com.br (Postfix) with ESMTP id 8608A4001D
	for <nfs@lists.sourceforge.net>; Thu, 21 Jul 2005 10:19:50 -0300 (BRT)
To: nfs@lists.sourceforge.net
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


Hello, all.

I'm having problems when mounting NFS in a Netapp FAS 740 filer on a
Linux RHAS4 Kernel 2.6 client. The message I get is:

[root@talara ~]# mount -a
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak
mount: RPC: Authentication error; why = Client credential too weak

Sometimes it works, most times it fails with the message above. If I use
the same setup above but with RH7.3 Kernel 2.4, it works without a
problem.

I found out this page that says it can be related to the client not
using privileged ports to do the mount:
http://teaparty.mathworks.com:1999/toasters/7212.html
(Or in Google's cache, only way I could open it:)
http://64.233.161.104/search?q=cache:K78rCZz1UnMJ:teaparty.mathworks.com:1999/toasters/7212.html+%22mount:+RPC:+Authentication+error%3B+why+%3D+Client+credential+too+weak%22+%2BNetapp&hl=en&start=1

This other post seems to confirm the issue:
http://www.archivum.info/netfilter/2002-03/msg00591.html

I also found a thread asking on how to force Linux to use privileged
ports, but it seemed the problem of the guy was another one, related to
MTU's, so that no solution to the unprivileged port was given.

So I ask:

- Anyone experienced this too?
- Is there a way on kernel 2.6 to force it to use privileged ports to do
the mount?
- This one is not related to Linux, but anyone knows if it's possible to
disable the privileged port restriction on the Netapp filer? This would
be acceptable to me to solve this problem.

I have tcpdump of a failed mounting session, so that I can provide it to
you upon request, if you think it could lead to some clue about what's
happening.

Thanks in advance!
Branden



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

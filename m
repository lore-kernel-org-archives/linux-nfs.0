From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Kernel 2.6 vs. Kernel 2.4: higher NFS traffic
Date: Tue, 26 Jul 2005 20:18:48 -0300
Message-ID: <20050726201432.22AA.BRANDEN@terra.com.br>
References: <20050726093038.FD8E.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxYhJ-0001nD-12
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 16:18:53 -0700
Received: from linares.terra.com.br ([200.154.55.228])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1DxYhH-0002nO-J6
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 16:18:53 -0700
Received: from congo.terra.com.br (congo.terra.com.br [200.176.10.2])
	by linares.terra.com.br (Postfix) with ESMTP id D94764DC031
	for <nfs@lists.sourceforge.net>; Tue, 26 Jul 2005 20:18:45 -0300 (BRT)
Received: from [200.176.1.176] (dsk17134-vm.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by congo.terra.com.br (Postfix) with ESMTP id C98B74006C
	for <nfs@lists.sourceforge.net>; Tue, 26 Jul 2005 20:18:45 -0300 (BRT)
To: nfs@lists.sourceforge.net
In-Reply-To: <20050726093038.FD8E.BRANDEN@terra.com.br>
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


Hi,

Regarding my net traffic problem, I noticed with tcpdump that a lot of
operations are RPC calls to the ACCESS function, then I read the FAQ and
found out the following:


http://nfs.sourceforge.net/#faq_b11
"The Linux NFS client should cache the results of these ACCESS
operations. In fact, in the new 2.6.x kernels, it does this and it
extends ACCESS checking to all users to allow for generic uid/gid
mapping on the server. This also enables proper support for Access
Control Lists in the server's local file system. In pre-2.6 kernels, the
stock NFS client does not cache the results of ACCESS operations."


Is there a way to disable this behaviour? To disable the ACCESS calls
for non-root users on kernel 2.6? I run all my applications as non-root
user, and one of the reasons for that is the lots of RPC calls to
v3access that begun to appear when upgrading from NFSv2 to NFSv3, so
that I actually see this behaviour on 2.6 a little as a negative factor
for upgrading from 2.4 to 2.6...

Thanks,
Filipe



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

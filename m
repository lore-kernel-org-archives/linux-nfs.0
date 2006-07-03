From: NeilBrown <neilb@suse.de>
Subject: [RFC PATCH 000 of 6] knfsd: change how sockets are assigned
	to nfsd and lockd
Date: Mon, 3 Jul 2006 16:19:05 +1000
Message-ID: <20060703161408.7009.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxHmA-0004iC-9k
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 23:19:18 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxHm9-0003l1-8g
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 23:19:18 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 78574EF03
	for <nfs@lists.sourceforge.net>; Mon,  3 Jul 2006 08:19:12 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

The following 6 patches are an RFC.  I'm not sending them to Andrew yet, but
plan to once the current merge window closes.

They allow fine control over what sockets nfsd listens on (userspace and
open a socket and pass the fd down - nfs-utils-1.0.9 will support this).
They allow course control over what sockets lockd listens on.
Lockd will only listen on a protocol that either:

 nfs is using for a mount
 nfsd is listening on
 a specific port was given as a module parameter.

Steve Dickson @ redhat helped with/motivated some of this development.

Comments welcome.

Thanks,
NeilBrown


 [PATCH 001 of 6] knfsd: Add a callback for when last rpc thread finishes.
 [PATCH 002 of 6] knfsd: Be more selective in which sockets lockd listens on.
 [PATCH 003 of 6] knfsd: Remove nfsd_versbits as intermediate storage for desired versions.
 [PATCH 004 of 6] knfsd: Separate out some parts of nfsd_svc, which start nfs servers.
 [PATCH 005 of 6] knfsd: Define new nfsdfs file: portlist - contains list of ports.
 [PATCH 006 of 6] knfsd: Allow sockets to be passed to nfsd via 'portlist'

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

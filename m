From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: NFSv3  not supported!
Date: Wed, 02 Jun 2004 10:07:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086185246.3424.8.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVWOu-0003IR-QU
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 07:07:28 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BVWOu-00018R-8u
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 07:07:28 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id F1004C422
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 10:07:18 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 08188-01 for <nfs@lists.sourceforge.net>;
	Wed, 2 Jun 2004 10:07:18 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 9ADC77971
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 10:07:18 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

I'm trying to mount a filesystem from an nfs server. The server is
running 2.6.6 kernel, and I've tried 2.6.6 and 2.6.7-rc2 on the client.
The client keeps reporting the following error when I try to mount using
nfsvers=3.
 
% sudo mount -o udp,intr,soft,nfsvers=3 nfsserver01:/services/NFS/home
/nfstest
NFSv3 not supported!
mount: wrong fs type, bad option, bad superblock on
nfsserver01:/services/NFS/home,
       or too many mounted file systems

I can mount using v2 without a problem, and I can mount a filesystem
from a 2.4 kernel using nfsvers=3 without a problem. Also, a different
machine running a 2.6.6 kernel can mount this filesystem without an
issue. The only problem is this one client. Can anyone point me in the
right direction to diagnose this?

NFSv3 is definitely enabled on the client:

laytonj@tesla:~% grep NFS /boot/config-2.6.7-rc2
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
# CONFIG_NFS_V4 is not set
CONFIG_NFS_DIRECTIO=y

I'm stumped! Any help is appreciated.

My current thinking is that this problem is related to the performance
issue I was seeing before. Once I get this worked out, I'll recheck my
NFS performance.

Thanks,
-- Jeff




-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.

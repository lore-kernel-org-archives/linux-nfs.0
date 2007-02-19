From: Chuck Lever <chuck.lever@oracle.com>
Subject: Announcing cel's patchset for 2.6.20
Date: Mon, 19 Feb 2007 08:58:39 -0800
Message-ID: <45D9D73F.9080706@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060209010204050308030203"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJBrQ-0002oP-V9
	for nfs@lists.sourceforge.net; Mon, 19 Feb 2007 08:59:33 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HJBrO-0003dE-IV
	for nfs@lists.sourceforge.net; Mon, 19 Feb 2007 08:59:32 -0800
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l1JGx1Ao006006
	for <nfs@lists.sourceforge.net>; Mon, 19 Feb 2007 10:59:01 -0600
Received: from rcsmt250.oracle.com (rcsmt250.oracle.com [148.87.90.195])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l1JGvNjT009552
	for <nfs@lists.sourceforge.net>; Mon, 19 Feb 2007 09:59:00 -0700
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

This is a multi-part message in MIME format.
--------------060209010204050308030203
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Cel's NFS and RPC patchset for the 2.6.20 kernel is now available here:

http://oss.oracle.com/~cel/linux-2.6/2.6.20/

and via git:

http://linux-nfs.org/cgi-bin/gitweb.cgi?p=cel-2.6.git;a=shortlog;h=cel-pub-2.6.20

This patch series contains the following:

1.  Patches now included in 2.6.21
2.  Remaining transport switch patches
3.  The new in-kernel rpcbind client implementation
4.  IPv6 support for the RPC client
5.  IPv6 support for the NFS client
6.  Unfinished IPv6 support for the RPC server
7.  Patches that remove the global kernel lock from the NFS client
8.  Experimental patches to clean up the XDR routines

--------------060209010204050308030203
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmUgTGludXggUHJvamVjdHMgR3Jv
dXANCmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRv
dCBjb20NCnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0
OCA2MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNh
cmQNCg0K
--------------060209010204050308030203
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------060209010204050308030203
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060209010204050308030203--

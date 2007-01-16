From: Chuck Lever <chuck.lever@oracle.com>
Subject: Announcing cel's patchset for 2.4.20-rc4
Date: Tue, 16 Jan 2007 11:25:42 -0500
Message-ID: <45ACFC86.1070800@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050004040406030405010601"
Cc: Chris Mason <chris.mason@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H6r99-0006nK-3W
	for nfs@lists.sourceforge.net; Tue, 16 Jan 2007 08:26:51 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H6r97-0003M8-Q4
	for nfs@lists.sourceforge.net; Tue, 16 Jan 2007 08:26:52 -0800
Received: from rgmsgw01.us.oracle.com (rgmsgw01.us.oracle.com [138.1.186.51])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l0GGQL4q032735
	for <nfs@lists.sourceforge.net>; Tue, 16 Jan 2007 09:26:21 -0700
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

This is a multi-part message in MIME format.
--------------050004040406030405010601
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

I've posted a "technology preview" release of my patch set for 2.4.20 at 
oss.oracle.com:

   http://oss.oracle.com/~cel/linux-2.4/2.4.20-rc4/

This is a preview to allow developers who use the patch set to learn 
about changes to the 2.6.20 version of the patch set before it is released.

This release includes:

o  the final patches in the RPC transport switch series
o  support for rpcbind protocol versions 3 and 4
o  RPC client support for IPv6
o  some support for IPv6 in the NFS client and RPC server
o  elimination of the global kernel lock from the NFS client
o  miscellaneous bug fixes and clean ups

The release notes have more details.

--------------050004040406030405010601
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmUgTGludXggUHJvamVjdHMgR3Jv
dXANCmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRv
dCBjb20NCnRpdGxlOlByaW5jaXBsZSBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0
OCA2MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNh
cmQNCg0K
--------------050004040406030405010601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------050004040406030405010601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050004040406030405010601--

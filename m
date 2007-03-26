From: Chuck Lever <chuck.lever@oracle.com>
Subject: cel's patches under development
Date: Mon, 26 Mar 2007 19:09:47 -0400
Message-ID: <460852BB.4080503@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070605030202050809000700"
Cc: Olaf Kirch <olaf.kirch@oracle.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVyKt-0002Nm-QL
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 16:10:50 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVyKu-0008HI-Su
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 16:10:50 -0700
Received: from rgmgw3.us.oracle.com (rgmgw3.us.oracle.com [138.1.186.112])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l2QNAeq6030195
	for <nfs@lists.sourceforge.net>; Mon, 26 Mar 2007 17:10:40 -0600
Received: from acsmt351.oracle.com (acsmt351.oracle.com [141.146.40.151])
	by rgmgw3.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l2QML72N010920
	for <nfs@lists.sourceforge.net>; Mon, 26 Mar 2007 17:10:40 -0600
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
--------------070605030202050809000700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This week's code drop is now available on linux-nfs.org in my git repo 
(cel-2.6.git) under the branch called drop-20070326.

This branch contains the remaining RPC transport switch patches against 
2.6.21-rc5, IPv6 patches (such as they are), BKL elimination patches, an 
immature set of in-kernel mount option parsing patches, and a long 
series of patches that rework the NFS client XDR routines.

The NFS XDR rewrite is partially finished.  The v2 and v3 routines are 
tested and working.  The NFSv4 encode routines are compile tested only, 
and the decode routines haven't been changed yet.

Plans include updates for NLM, rpcbind, and NFSROOT MNT.

--------------070605030202050809000700
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture -- Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070605030202050809000700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070605030202050809000700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070605030202050809000700--

From: Simon Peter <simon.peter@gmx.de>
Subject: nfs-utils inode cache patch
Date: Fri, 9 Mar 2007 18:09:21 +0100
Message-ID: <20070309180921.57ae908c.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="Multipart=_Fri__9_Mar_2007_18_09_21_+0100_1uidOvrfK3bjdShz"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPib3-00006b-Rx
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 09:09:38 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HPib1-0007ws-GM
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 09:09:37 -0800
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

--Multipart=_Fri__9_Mar_2007_18_09_21_+0100_1uidOvrfK3bjdShz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Hi Neil,

okay, here's the patch making the kernel cache inode data of exported
directories forever, thus avoiding unnecessary disk spin-ups when this
data is looked for. It looks correct, works for me and both Bruce and
you have been encouraging it. :) Would be great if that could go into
nfs-utils.

Thanks,
Simon

--Multipart=_Fri__9_Mar_2007_18_09_21_+0100_1uidOvrfK3bjdShz
Content-Type: video/dv;
 name="nfs-utils-1.0.12-cache.dif"
Content-Disposition: attachment;
 filename="nfs-utils-1.0.12-cache.dif"
Content-Transfer-Encoding: base64

ZGlmZiAtdSAtciBuZnMtdXRpbHMtMS4wLjEyL3V0aWxzL21vdW50ZC9jYWNoZS5jIG5mcy11dGls
cy0xLjAuMTItbmV3L3V0aWxzL21vdW50ZC9jYWNoZS5jCi0tLSBuZnMtdXRpbHMtMS4wLjEyL3V0
aWxzL21vdW50ZC9jYWNoZS5jCTIwMDctMDItMjcgMDU6NTU6NDAuMDAwMDAwMDAwICswMTAwCisr
KyBuZnMtdXRpbHMtMS4wLjEyLW5ldy91dGlscy9tb3VudGQvY2FjaGUuYwkyMDA3LTAzLTA4IDEx
OjUyOjMzLjAwMDAwMDAwMCArMDEwMApAQCAtNDEzLDcgKzQxNiw3IEBACiAJcXdvcmRfcHJpbnQo
ZiwgZG9tKTsKIAlxd29yZF9wcmludGludChmLCBmc2lkdHlwZSk7CiAJcXdvcmRfcHJpbnRoZXgo
ZiwgZnNpZCwgZnNpZGxlbik7Ci0JcXdvcmRfcHJpbnRpbnQoZiwgdGltZSgwKSszMCo2MCk7CisJ
cXdvcmRfcHJpbnRpbnQoZiwgMHg3ZmZmZmZmZik7CiAJaWYgKGZvdW5kKQogCQlxd29yZF9wcmlu
dChmLCBmb3VuZC0+ZV9wYXRoKTsKIAlxd29yZF9lb2woZik7Cg==

--Multipart=_Fri__9_Mar_2007_18_09_21_+0100_1uidOvrfK3bjdShz
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--Multipart=_Fri__9_Mar_2007_18_09_21_+0100_1uidOvrfK3bjdShz
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Multipart=_Fri__9_Mar_2007_18_09_21_+0100_1uidOvrfK3bjdShz--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:23803 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565Ab3KYVGs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 16:06:48 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 fix a kswap nfs4_state_manger race
Date: Mon, 25 Nov 2013 21:06:44 +0000
Message-ID: <1385413604.9247.3.camel@leira.trondhjem.org>
References: <1385402270-14284-1-git-send-email-andros@netapp.com>
	 <1385402270-14284-2-git-send-email-andros@netapp.com>
	 <5B8C7A9D-CD9E-487A-AC62-B1292649835D@netapp.com>
	 <496E7DBC-183B-43A2-91D4-837FC092E88A@netapp.com>
	 <676D25D8-B845-42BC-BB1E-6441B6B8E5E3@netapp.com>
	 <5BE68579-3F17-4786-89B9-21CEC1A94E8E@netapp.com>
	 <48468258-591E-49A8-9EAA-2DD8E3993100@netapp.com>
	 <A18682DD-86C4-47C0-89F4-B8298F918AC9@netapp.com>
	 <3A65AD2F-797E-4292-BA9C-4CF20BD075CB@netapp.com>
In-Reply-To: <3A65AD2F-797E-4292-BA9C-4CF20BD075CB@netapp.com>
Content-Type: multipart/mixed;
	boundary="_002_138541360492473camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_138541360492473camelleiratrondhjemorg_
Content-Type: text/plain; charset="utf-7"
Content-ID: <E19606406E386349997D5F90C8C0C900@hq.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-11-25 at 20:29 +-0000, Adamson, Andy wrote:
+AD4- On Nov 25, 2013, at 3:20 PM, +ACI-Myklebust, Trond+ACI- +ADw-Trond.My=
klebust+AEA-netapp.com+AD4-
+AD4-  wrote:
+AD4-=20
+AD4- +AD4-=20
+AD4- +AD4- On Nov 25, 2013, at 15:10, Adamson, Andy +ADw-William.Adamson+A=
EA-netapp.com+AD4- wrote:
+AD4- +AD4-=20
+AD4- +AD4APg-=20
+AD4- +AD4APg- On Nov 25, 2013, at 2:53 PM, +ACI-Myklebust, Trond+ACI- +ADw=
-Trond.Myklebust+AEA-netapp.com+AD4-
+AD4- +AD4APg- wrote:
+AD4- +AD4APg-=20
+AD4- +AD4APgA+-=20
+AD4- +AD4APgA+- On Nov 25, 2013, at 14:27, Adamson, Andy +ADw-William.Adam=
son+AEA-netapp.com+AD4- wrote:
+AD4- +AD4APgA+-=20
+AD4- +AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4- On Nov 25, 2013, at 1:33 PM, +ACI-Myklebust, Trond+ACI-=
 +ADw-Trond.Myklebust+AEA-netapp.com+AD4-
+AD4- +AD4APgA+AD4- wrote:
+AD4- +AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4APg-=20
+AD4- +AD4APgA+AD4APg- On Nov 25, 2013, at 13:13, Myklebust, Trond +ADw-Tro=
nd.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- +AD4APgA+AD4APg-=20
+AD4- +AD4APgA+AD4APgA+-=20
+AD4- +AD4APgA+AD4APgA+- On Nov 25, 2013, at 12:57, +ADw-andros+AEA-netapp.=
com+AD4- +ADw-andros+AEA-netapp.com+AD4- wrote:
+AD4- +AD4APgA+AD4APgA+-=20
+AD4- +AD4APgA+AD4APgA+AD4- From: Andy Adamson +ADw-andros+AEA-netapp.com+A=
D4-
+AD4- +AD4APgA+AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4APgA+AD4- The state manager is recovering expired state a=
nd recovery OPENs are being
+AD4- +AD4APgA+AD4APgA+AD4- processed. If kswapd is pruning inodes at the s=
ame time, a deadlock can occur
+AD4- +AD4APgA+AD4APgA+AD4- when kswapd calls evict+AF8-inode on an NFSv4.1=
 inode with a layout, and the
+AD4- +AD4APgA+AD4APgA+AD4- resultant layoutreturn gets an error that the s=
tate mangager is to handle,
+AD4- +AD4APgA+AD4APgA+AD4- causing the layoutreturn to wait on the (NFS cl=
ient) cl+AF8-rpcwaitq.
+AD4- +AD4APgA+AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4APgA+AD4- At the same time an open is waiting for the ino=
de deletion to complete in
+AD4- +AD4APgA+AD4APgA+AD4- +AF8AXw-wait+AF8-on+AF8-freeing+AF8-inode.
+AD4- +AD4APgA+AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4APgA+AD4- If the open is either the open called by the st=
ate manager, or an open from
+AD4- +AD4APgA+AD4APgA+AD4- the same open owner that is holding the NFSv4.0=
 sequence id which causes the
+AD4- +AD4APgA+AD4APgA+AD4- OPEN from the state manager to wait for the seq=
uence id on the Seqid+AF8-waitqueue,
+AD4- +AD4APgA+AD4APgA+AD4- then the state is deadlocked with kswapd.
+AD4- +AD4APgA+AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4APgA+AD4- Do not handle LAYOUTRETURN errors when called f=
rom nfs4+AF8-evict+AF8-inode.
+AD4- +AD4APgA+AD4APgA+-=20
+AD4- +AD4APgA+AD4APgA+- Why are we waiting for recovery in LAYOUTRETURN at=
 all? Layouts are automatically lost when the server reboots or when the le=
ase is otherwise lost.
+AD4- +AD4APgA+AD4APgA+-=20
+AD4- +AD4APgA+AD4APgA+- IOW: Is there any reason why we need to special-ca=
se nfs4+AF8-evict+AF8-inode? Shouldn+IBk-t we just bail out on error in +AF=
8-all+AF8- cases?
+AD4- +AD4APgA+AD4APg-=20
+AD4- +AD4APgA+AD4APg- BTW: Is it possible that we might have a similar pro=
blem with delegreturn? That too can be called from nfs4+AF8-evict+AF8-inode=
+ICY-
+AD4- +AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4- Yes, good point.  kswapd could be waiting for a delegat=
ion to return which has an error along with the same scenario with sys+AF8-=
open and the state manager running.
+AD4- +AD4APgA+AD4-=20
+AD4- +AD4APgA+AD4- With delegreturn, we most definately want to limit 'no =
error handling' to the evict inode case.
+AD4- +AD4APgA+-=20
+AD4- +AD4APgA+- Ah+ICY- I forgot that the delegreturn in nfs4+AF8-evict+AF=
8-inode is asynchronous and doesn+IBk-t wait for completion, so it shouldn+=
IBk-t be a problem here.
+AD4- +AD4APg-=20
+AD4- +AD4APg- Except we just changed that to fix a different state manager=
 hang:
+AD4- +AD4APg-=20
+AD4- +AD4APg- commit 4a82fd7c4e78a1b7a224f9ae8bb7e1fd95f670e0
+AD4- +AD4APg- Author: Andy Adamson +ADw-andros+AEA-netapp.com+AD4-
+AD4- +AD4APg- Date:   Fri Nov 15 16:36:16 2013 -0500
+AD4- +AD4APg-=20
+AD4- +AD4APg-   NFSv4 wait on recovery for async session errors
+AD4- +AD4-=20
+AD4- +AD4- Right, but that won+IBk-t prevent nfs4+AF8-evict+AF8-inode from=
 completing,
+AD4-=20
+AD4- Ah - I was thinking of the synchronous handlers call to nfs4+AF8-wait=
+AF8-clnt+AF8-recover - so yes, no problem
+AD4-=20
+AD4- --+AD4-Andy
+AD4-=20
+AD4- +AD4- and hence the OPEN that is waiting in nfs+AF8-fhget() can also =
complete, and so there is no deadlock with the state manager thread.

How about something like the attached...

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_138541360492473camelleiratrondhjemorg_
Content-Type: text/x-patch; name="patch.dif"
Content-Description: patch.dif
Content-Disposition: attachment; filename="patch.dif"; size=604;
	creation-date="Mon, 25 Nov 2013 21:06:44 GMT";
	modification-date="Mon, 25 Nov 2013 21:06:44 GMT"
Content-ID: <B1110B107A94894FB8CE5C2FE95CFF7B@hq.netapp.com>
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnM0cHJvYy5jIGIvZnMvbmZzL25mczRwcm9jLmMNCmluZGV4
IGYwMWUyYWE1MzIxMC4uZTA0MDM1OTk4M2NlIDEwMDY0NA0KLS0tIGEvZnMvbmZzL25mczRwcm9j
LmMNCisrKyBiL2ZzL25mcy9uZnM0cHJvYy5jDQpAQCAtNzU5OSw3ICs3NTk5LDE0IEBAIHN0YXRp
YyB2b2lkIG5mczRfbGF5b3V0cmV0dXJuX2RvbmUoc3RydWN0IHJwY190YXNrICp0YXNrLCB2b2lk
ICpjYWxsZGF0YSkNCiAJCXJldHVybjsNCiANCiAJc2VydmVyID0gTkZTX1NFUlZFUihscnAtPmFy
Z3MuaW5vZGUpOw0KLQlpZiAobmZzNF9hc3luY19oYW5kbGVfZXJyb3IodGFzaywgc2VydmVyLCBO
VUxMKSA9PSAtRUFHQUlOKSB7DQorCXN3aXRjaCAodGFzay0+dGtfc3RhdHVzKSB7DQorCWRlZmF1
bHQ6DQorCQl0YXNrLT50a19zdGF0dXMgPSAwOw0KKwljYXNlIDA6DQorCQlicmVhazsNCisJY2Fz
ZSAtTkZTNEVSUl9ERUxBWToNCisJCWlmIChuZnM0X2FzeW5jX2hhbmRsZV9lcnJvcih0YXNrLCBz
ZXJ2ZXIsIE5VTEwpICE9IC1FQUdBSU4pDQorCQkJYnJlYWs7DQogCQlycGNfcmVzdGFydF9jYWxs
X3ByZXBhcmUodGFzayk7DQogCQlyZXR1cm47DQogCX0NCg==

--_002_138541360492473camelleiratrondhjemorg_--

From: "Chen Huan" <huanchen@ncic.ac.cn>
Subject: about sunrpc svc_receive
Date: Mon, 19 Dec 2005 15:10:46 +0800
Message-ID: <20051219071307.71330FB045@gatekeeper.ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EoFAk-0006MV-Ha
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 23:11:02 -0800
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188] helo=ncic.ac.cn)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EoFAi-0005TS-SM
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 23:11:02 -0800
Received: from chenhuan (trumpet.ncic.ac.cn [159.226.41.129])
	by gatekeeper.ncic.ac.cn (Postfix) with SMTP id 71330FB045
	for <nfs@lists.sourceforge.net>; Mon, 19 Dec 2005 15:13:07 +0800 (CST)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
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

aGVsbG+joQ0KCQ0KV2hhdCBpcyB0aGUgbWVhbmluZyBvZiB0aGUgZm9sbG93aW5nIGNvZGUgaW4g
c3VucnBjL3N2Y3NvY2suYyA/DQoNCioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioNCnN2Y19yZWN2KCApew0KICAgICAgICAgICAgICAgLg0KCQkJ
ICAgLg0KCQkJICAgLg0KCWNsZWFyX2JpdChTS19EQVRBLCAmc3Zzay0+c2tfZmxhZ3MpOw0KCXdo
aWxlICgoc2tiID0gc2tiX3JlY3ZfZGF0YWdyYW0oc3Zzay0+c2tfc2ssIDAsIDEsICZlcnIpKSA9
PSBOVUxMKSB7DQoJCXN2Y19zb2NrX3JlY2VpdmVkKHN2c2spOyAgICAgLyogPz8/PyAgKi8NCgkJ
aWYgKGVyciA9PSAtRUFHQUlOKQ0KCQkJcmV0dXJuIGVycjsNCgkJZHByaW50aygic3ZjOiByZWN2
ZnJvbSByZXR1cm5lZCBlcnJvciAlZFxuIiwgLWVycik7DQoJfQ0KCXNldF9iaXQoU0tfREFUQSwg
JnN2c2stPnNrX2ZsYWdzKTsgDQoJCQkgICAuDQoJCQkgICAuDQoJCQkgICAuDQp9DQoqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioNCndoeSBu
ZWVkICBzdmNfc29ja19yZWNlaXZlZChzdnNrKSBzaW5jZSB0aGVyZSBpcyBubyBkYXRhIHJlY2Vp
dmVkPw0KDQoNCgkJCQ0K



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

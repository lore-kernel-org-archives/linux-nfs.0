From: =?ks_c_5601-1987?B?seiw5sel?= <kpkim@gluesys.com>
Subject: nfsd hang !!! RPC request reserved -1453504422 but used 116
Date: Fri, 5 Aug 2005 18:52:53 +0900
Message-ID: <000a01c599a3$730fc720$6b00a8c0@hgichon>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0007_01C599EE.E2CC8E90"
Cc: <kgh@gluesys.com>, <jgchoi@gluesys.com>, <gbkwon@gluesys.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E0ysN-0000Qf-Q3
	for nfs@lists.sourceforge.net; Fri, 05 Aug 2005 02:52:27 -0700
Received: from mailgate1.kt-idc.co.kr ([211.62.35.98] helo=mailgate1.mailhost2.kornet.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E0ysN-0000qO-3i
	for nfs@lists.sourceforge.net; Fri, 05 Aug 2005 02:52:28 -0700
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------=_NextPart_000_0007_01C599EE.E2CC8E90
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: base64

SGksDQoNClRocmVlIGRheXMgYWdvLCBJIGdvdCB0aGUgbWVzc2FnZSAiUlBDIHJlcXVlc3QgcmVz
ZXJ2ZWQgLTE0NTM1MDQ0MjIgYnV0IHVzZWQgMTE2IiBpbiBteSBsaW51eCBib3guDQpXaGVuIHRo
ZSBtZXNzYWdlIGlzc3VlZCwgbXkgbmZzZCBpcyBub3QgcmVzcG9uZC4NCg0KLS0tIE5GUyBzZXJ2
ZXIgLS0tDQpsaW51eC0yLjQuMjcNCmZpbGVzeXN0ZW0gOiB4ZnMNCg0KLS0tIE5GUyBDbGllbnQg
LS0tDQpsaW51eC0yLjQuMzENClJlZGhhdCA3LjINCmFwcGxpY2F0aW9uIGFwYWNoZS1saW5nZXIt
MS4zLjMzDQoNCi0tLSBDb25maWd1cmF0aW9uIC0tLQ0KTkZTIHNlcnZlciBleHBvcnQgb3B0aW9u
IDogYXN5bmMsIHJ3DQpORlMgQ2xpZW50IG1vdW50IG9wdGlvbiA6IG5vYXRpbWUsIHVkcA0KDQoN
CkFuZCBhIHdlZWsgYWdvLCBORlMgc2VydmVyIHdhcyBjcmFzaGVkIGFuZCBObyBwaW5nLg0KSSBj
YW4ndCBmaW5kIGFueSBrZXJuZWwgbWVzc2FnZSBkdW1wLg0KDQpJIGRvbid0IGtub3cgdGhhdCBh
Ym92ZSAyIHByb2JsZW0gaXMgcmVsYXRlZC4NCg0KUGxlYXNlIGhlbHAhDQpUaGFua3Mu

------=_NextPart_000_0007_01C599EE.E2CC8E90
Content-Type: text/html;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: base64

PCFET0NUWVBFIEhUTUwgUFVCTElDICItLy9XM0MvL0RURCBIVE1MIDQuMCBUcmFuc2l0aW9uYWwv
L0VOIj4NCjxIVE1MPjxIRUFEPg0KPE1FVEEgaHR0cC1lcXVpdj1Db250ZW50LVR5cGUgY29udGVu
dD0idGV4dC9odG1sOyBjaGFyc2V0PWtzX2NfNTYwMS0xOTg3Ij4NCjxNRVRBIGNvbnRlbnQ9Ik1T
SFRNTCA2LjAwLjI4MDAuMTUwNSIgbmFtZT1HRU5FUkFUT1I+DQo8U1RZTEU+PC9TVFlMRT4NCjwv
SEVBRD4NCjxCT0RZIGJnQ29sb3I9I2ZmZmZmZj4NCjxESVY+PEZPTlQgc2l6ZT0yPkhpLDwvRk9O
VD48L0RJVj4NCjxESVY+PEZPTlQgc2l6ZT0yPjwvRk9OVD4mbmJzcDs8L0RJVj4NCjxESVY+PEZP
TlQgc2l6ZT0yPlRocmVlJm5ic3A7ZGF5cyBhZ28sIEkgZ290IHRoZSBtZXNzYWdlICJSUEMgcmVx
dWVzdCByZXNlcnZlZCANCi0xNDUzNTA0NDIyIGJ1dCB1c2VkIDExNiIgaW4gbXkgbGludXggYm94
LjwvRk9OVD48L0RJVj4NCjxESVY+PEZPTlQgc2l6ZT0yPldoZW4gdGhlIG1lc3NhZ2UgaXNzdWVk
LCBteSBuZnNkIGlzIG5vdCByZXNwb25kLjwvRk9OVD48L0RJVj4NCjxESVY+PEZPTlQgc2l6ZT0y
PjwvRk9OVD4mbmJzcDs8L0RJVj4NCjxESVY+PEZPTlQgc2l6ZT0yPi0tLSBORlMgc2VydmVyIC0t
LTwvRk9OVD48L0RJVj4NCjxESVY+PEZPTlQgc2l6ZT0yPmxpbnV4LTIuNC4yNzwvRk9OVD48L0RJ
Vj4NCjxESVY+PEZPTlQgc2l6ZT0yPmZpbGVzeXN0ZW0gOiB4ZnM8L0ZPTlQ+PC9ESVY+DQo8RElW
PjxGT05UIHNpemU9Mj48L0ZPTlQ+Jm5ic3A7PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj4tLS0g
TkZTIENsaWVudCAtLS08L0ZPTlQ+PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj5saW51eC0yLjQu
MzE8L0ZPTlQ+PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj5SZWRoYXQgNy4yPC9GT05UPjwvRElW
Pg0KPERJVj48Rk9OVCBzaXplPTI+YXBwbGljYXRpb24gYXBhY2hlLWxpbmdlci0xLjMuMzM8L0ZP
TlQ+PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj48L0ZPTlQ+Jm5ic3A7PC9ESVY+DQo8RElWPjxG
T05UIHNpemU9Mj4tLS0gQ29uZmlndXJhdGlvbiAtLS08L0ZPTlQ+PC9ESVY+DQo8RElWPjxGT05U
IHNpemU9Mj5ORlMgc2VydmVyIGV4cG9ydCZuYnNwO29wdGlvbiA6Jm5ic3A7YXN5bmMsIHJ3PC9G
T05UPjwvRElWPg0KPERJVj48Rk9OVCBzaXplPTI+TkZTIENsaWVudCBtb3VudCBvcHRpb24gOiBu
b2F0aW1lLCB1ZHA8L0ZPTlQ+PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj48L0ZPTlQ+Jm5ic3A7
PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj48L0ZPTlQ+Jm5ic3A7PC9ESVY+DQo8RElWPjxGT05U
IHNpemU9Mj5BbmQmbmJzcDthIHdlZWsgYWdvLCZuYnNwO05GUyBzZXJ2ZXImbmJzcDt3YXMgY3Jh
c2hlZCBhbmQgTm8gDQpwaW5nLjwvRk9OVD48L0RJVj4NCjxESVY+PEZPTlQgc2l6ZT0yPkkgY2Fu
J3QgZmluZCBhbnkga2VybmVsIG1lc3NhZ2UgZHVtcC48L0ZPTlQ+PC9ESVY+DQo8RElWPjxGT05U
IHNpemU9Mj48L0ZPTlQ+Jm5ic3A7PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj5JIGRvbid0IGtu
b3cgdGhhdCBhYm92ZSAyIHByb2JsZW0gaXMgcmVsYXRlZC48L0ZPTlQ+PC9ESVY+DQo8RElWPjxG
T05UIHNpemU9Mj48L0ZPTlQ+Jm5ic3A7PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj5QbGVhc2Ug
aGVscCE8L0ZPTlQ+PC9ESVY+DQo8RElWPjxGT05UIHNpemU9Mj5UaGFua3MuPC9GT05UPjwvRElW
PjwvQk9EWT48L0hUTUw+DQo=

------=_NextPart_000_0007_01C599EE.E2CC8E90--



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

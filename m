From: "Ming.W.Xia" <mingwxia@hotmail.com>
Subject: no-root user can not mount a remote nfs directory?
Date: Tue, 14 Dec 2004 14:58:06 +0800
Message-ID: <BAY16-DAV32B09C9B4395F91D6DE08C5AC0@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0041_01C4E1ED.5146CDF0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce6cO-0006lP-8c
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 22:57:08 -0800
Received: from bay16-dav3.bay16.hotmail.com ([65.54.186.183] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ce6cN-00060Q-Vw
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 22:57:08 -0800
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

------=_NextPart_000_0041_01C4E1ED.5146CDF0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: base64

aGkgYWxsLA0KV2hlbiBJIGlzc3VlIHRoZSAnbW91bnQgLXQgbmZzJyBjb21tYW5kIHRvIG1vdW50
IGEgcmVtb3RlIGV4cG9ydGVkIG5mcyANCmRpcmVjdG9yeSAsIEkgZ290IHRoZSBtZXNzYWdlICJt
b3VudDogb25seSByb290IGNhbiBkbyB0aGF0Ii4gRG9lcyBpdCANCm1lYW4gbm8tcm9vdCB1c2Vy
cyBjYW4gbm90IHVzZXIgbmZzPw0KDQpyZWdhcmRzIA==

------=_NextPart_000_0041_01C4E1ED.5146CDF0
Content-Type: text/html;
	charset="gb2312"
Content-Transfer-Encoding: base64

PCFET0NUWVBFIEhUTUwgUFVCTElDICItLy9XM0MvL0RURCBIVE1MIDQuMCBUcmFuc2l0aW9uYWwv
L0VOIj4NCjxIVE1MPjxIRUFEPg0KPE1FVEEgaHR0cC1lcXVpdj1Db250ZW50LVR5cGUgY29udGVu
dD0idGV4dC9odG1sOyBjaGFyc2V0PWdiMjMxMiI+DQo8TUVUQSBjb250ZW50PSJNU0hUTUwgNi4w
MC4yODAwLjE0MDAiIG5hbWU9R0VORVJBVE9SPg0KPFNUWUxFPjwvU1RZTEU+DQo8L0hFQUQ+DQo8
Qk9EWSBiZ0NvbG9yPSNmZmZmZmY+DQo8RElWPjxGT05UIGZhY2U9IkNvdXJpZXIgTmV3IiBzaXpl
PTI+aGkgYWxsLDwvRk9OVD48L0RJVj4NCjxESVY+PEZPTlQgZmFjZT0iQ291cmllciBOZXciIHNp
emU9Mj5XaGVuIEkgaXNzdWUgdGhlICdtb3VudCAtdCANCm5mcycmbmJzcDtjb21tYW5kIHRvIG1v
dW50IGEgcmVtb3RlJm5ic3A7ZXhwb3J0ZWQgbmZzIDwvRk9OVD48L0RJVj4NCjxESVY+PEZPTlQg
ZmFjZT0iQ291cmllciBOZXciIHNpemU9Mj5kaXJlY3RvcnkgLCBJJm5ic3A7Z290IHRoZSBtZXNz
YWdlICJtb3VudDogDQpvbmx5IHJvb3QgY2FuIGRvIHRoYXQiLiZuYnNwO0RvZXMgaXQgPC9GT05U
PjwvRElWPg0KPERJVj48Rk9OVCBmYWNlPSJDb3VyaWVyIE5ldyIgc2l6ZT0yPm1lYW4mbmJzcDtu
by1yb290IHVzZXJzIGNhbiBub3QgdXNlciANCm5mcz88L0ZPTlQ+PC9ESVY+DQo8RElWPiZuYnNw
OzwvRElWPg0KPERJVj48Rk9OVCBmYWNlPSJDb3VyaWVyIE5ldyIgc2l6ZT0yPnJlZ2FyZHM8L0ZP
TlQ+Jm5ic3A7PC9ESVY+PC9CT0RZPjwvSFRNTD4NCg==

------=_NextPart_000_0041_01C4E1ED.5146CDF0--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

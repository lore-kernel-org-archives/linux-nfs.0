From: "Choi" <cinch@newmail.naver.com>
Subject: rpc.statd died with segmentation fault..
Date: Fri, 15 Nov 2002 01:48:27 +0900 (KST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DD3D3DB.000001.00825@naver779.naver.com>
Reply-To: <cinch@newmail.naver.com>
Mime-Version: 1.0
Content-Type: Multipart/Alternative;
  boundary="------------Boundary-00=_R0SKULUXFQQMYJ0CCJD0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [211.218.150.188] (helo=naver779.naver.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CNAN-0002NO-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 08:48:31 -0800
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--------------Boundary-00=_R0SKULUXFQQMYJ0CCJD0
Content-Type: Text/Plain;
  charset="euc-kr"
Content-Transfer-Encoding: base64

SSBhbSB1c2luZyBMSU5VWCAyLjQuMTggS2VybmVsLg0KYW5kIExpbnV4IGFzIGEgbmZzIGNsaWVu
dCwgTmV0QXBwIEZpbGVyIGFzIGEgTkZTIFNlcnZlci4NCnJwYy5zdGF0ZCB2ZXJzaW9uIGlzIDAu
My4zDQoNCmFmdGVyIHJlYm9vdCwgcnBjLnN0YXRkIGlzIHJ1bm5pbmcgd2l0aG91dCBubyBwcm9i
bGVtLg0KV2hlbiBteSBwcm9ncmFtIGluIExJTlVYIHRyaWVzIHRvIGdldCBXUklURSBsb2NrIG9u
IGEgZmlsZSBpbiB0aGUgTkZTIHNlcnZlciwNCnJwYy5zdGF0ZCBkaWVkLi4uDQoNCklmIEkgcnVu
IHJwYy5zdGF0ZCB3aXRoICIgcnBjc3RhdGQgLUYgLWQgIiwgdGhpcyBwcm9ibGVtIGRvZXNuJ3Qg
aGFwcGVuLg0KYnV0IHJwYy5zdGF0ZCBpcyBleGVjdXRlZCBhcyBhIGRhZW1vbiwgaXQgZGllZCAu
Li4NCg0KV2hlbiBJIHRyYWNlZCBycGMuc3RhdGQgd2l0aCBzdHJhY2UgdXRpbGl0eSwgSSBmb3Vu
ZCBvdXQNCnJwYy5zdGF0ZCBkaWVkIHdpdGggc2VnbWVudGF0aW9uIGZhdWx0IGFmdGVyIHJlcGx5
aW5nIHJlcXVlc3QuLg0KDQoNCnBsZWFzZSwgbGV0IG1lIGtub3cgd2h5IC4uLj8NCg==

--------------Boundary-00=_R0SKULUXFQQMYJ0CCJD0
Content-Type: Text/HTML;
  charset="euc-kr"
Content-Transfer-Encoding: base64

PFNUWUxFPgpCT0RZIHtGT05ULUZBTUlMWTogsby4sjtGT05ULVNJWkU6IDEwcHQ7fQpQIHttYXJn
aW4tdG9wOjJweDttYXJnaW4tYm90dG9tOjJweDt9CjwvU1RZTEU+CkkgYW0gdXNpbmcgTElOVVgg
Mi40LjE4IEtlcm5lbC4NPEJSPgphbmQgTGludXggYXMgYSBuZnMgY2xpZW50LCBOZXRBcHAgRmls
ZXIgYXMgYSBORlMgU2VydmVyLg08QlI+CnJwYy5zdGF0ZCB2ZXJzaW9uIGlzIDAuMy4zDTxCUj4K
DTxCUj4KYWZ0ZXIgcmVib290LCBycGMuc3RhdGQgaXMgcnVubmluZyB3aXRob3V0IG5vIHByb2Js
ZW0uDTxCUj4KV2hlbiBteSBwcm9ncmFtIGluIExJTlVYIHRyaWVzIHRvIGdldCBXUklURSBsb2Nr
IG9uIGEgZmlsZSBpbiB0aGUgTkZTIHNlcnZlciwNPEJSPgpycGMuc3RhdGQgZGllZC4uLg08QlI+
Cg08QlI+CklmIEkgcnVuIHJwYy5zdGF0ZCB3aXRoICIgcnBjc3RhdGQgLUYgLWQgIiwgdGhpcyBw
cm9ibGVtIGRvZXNuJ3QgaGFwcGVuLg08QlI+CmJ1dCBycGMuc3RhdGQgaXMgZXhlY3V0ZWQgYXMg
YSBkYWVtb24sIGl0IGRpZWQgLi4uDTxCUj4KDTxCUj4KV2hlbiBJIHRyYWNlZCBycGMuc3RhdGQg
d2l0aCBzdHJhY2UgdXRpbGl0eSwgSSBmb3VuZCBvdXQNPEJSPgpycGMuc3RhdGQgZGllZCB3aXRo
IHNlZ21lbnRhdGlvbiBmYXVsdCBhZnRlciByZXBseWluZyByZXF1ZXN0Li4NPEJSPgoNPEJSPgoN
PEJSPgpwbGVhc2UsIGxldCBtZSBrbm93IHdoeSAuLi4/DTxCUj4KPElNRyBTUkM9aHR0cDovL25h
dmVyNzc5Lm5hdmVyLmNvbS9tYWlsY2hlY2svY2hlY2s/bWFpbGluZm89VnFuZTF6RjUxNkY5N3Ew
cU02JTJGVGJya1pwelVtS0xZd2FWWXdhVmVvMTZsbzFWWXNLb3VaRlNtWkt4VTkgYm9yZGVyPTA+
PFA+Jm5ic3A7PEJSPjwvUD48cD4KPHNtYWxsPgo8dGFibGUgY2VsbHBhZGRpbmc9MSBjZWxsc3Bh
Y2luZz0wIGJvcmRlcj0wPgo8dHI+PHRkPjxhIGhyZWY9aHR0cDovL3d3dy5uYXZlci5jb20vIHRh
cmdldD1faGVscD48aW1nIHNyYz1odHRwOi8vc3RhdGljLm5hdmVyLmNvbS9tYWlsL2ltYWdlczIv
dGFpbC9sb2dvX20uZ2lmIGJvcmRlcj0wPjwvYT48L3RkPjwvdHI+Cjx0cj48dGQgaGVpZ2h0PTQ+
PHRhYmxlIGhlaWdodD00IGNlbGxwYWRkaW5nPTAgY2VsbHNwYWNpbmc9MCBib3JkZXI9MD48dHI+
PHRkPjwvdGQ+PC90cj48L3RhYmxlPjwvdGQ+PC90cj4KPHRyPjx0ZD48c21hbGw+u/2wosfPtMIg
wfa0ycf8ILDLu/Ygs9fAzLn2ILPYvK3EoTwvc21hbGw+PC90ZD48L3RyPgo8dHI+PHRkPjxzbWFs
bD7Gr7qwx9EgZSC43sDPwLsgv/jH0iC2qSwgvvex17e5wMy15SCz18DMufYguN7Azzwvc21hbGw+
PC90ZD48L3RyPgo8dHI+PHRkPjxzbWFsbD48YSBocmVmPWh0dHA6Ly93d3cubmF2ZXIuY29tLyB0
YXJnZXQ9X2hlbHA+PGZvbnQgY29sb3I9IzAwMDBmZj5odHRwOi8vd3d3Lm5hdmVyLmNvbTwvZm9u
dD48L2E+PC9zbWFsbD48L3RkPjwvdHI+CjwvdGFibGU+Cjwvc21hbGw+Cgo=

--------------Boundary-00=_R0SKULUXFQQMYJ0CCJD0--


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

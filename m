From: Eugene <hdejin@yahoo.com>
Subject: nfs-utils-1.0.8-rc2: Makefile DESTDIR problem
Date: Wed, 4 Jan 2006 04:57:48 -0800 (PST)
Message-ID: <20060104125748.23937.qmail@web50211.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-420900565-1136379468=:23661"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu8DF-0007Ul-7w
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:57:57 -0800
Received: from web50211.mail.yahoo.com ([206.190.39.175])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Eu8DC-0005BK-DP
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:57:57 -0800
To: nfs@lists.sourceforge.net
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

--0-420900565-1136379468=:23661
Content-Type: text/plain; charset=iso-8859-1
Content-Id: 
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The generated Makefile from Makefile.am does not
honour the DESTDIR variable when installing
$(statedir). (ie it attempts to install to the root
prefix rather than the staging directory). Attached is
a patch.

Rgds.
- Eugene


	=09
__________________________________________=20
Yahoo! DSL =96 Something to write home about.=20
Just $16.99/mo. or less.=20
dsl.yahoo.com=20

--0-420900565-1136379468=:23661
Content-Type: application/octet-stream; name="Makefile.am.patch"
Content-Transfer-Encoding: base64
Content-Description: 4143770890-Makefile.am.patch
Content-Disposition: attachment; filename="Makefile.am.patch"

LS0tIG5mcy11dGlscy0xLjAuOC1yYzIub3JpZy9NYWtlZmlsZS5hbQkyMDA2
LTAxLTA0IDIwOjMxOjA3LjAwMDAwMDAwMCArMDgwMAorKysgbmZzLXV0aWxz
LTEuMC44LXJjMi9NYWtlZmlsZS5hbQkyMDA2LTAxLTA0IDIwOjM2OjI4LjAw
MDAwMDAwMCArMDgwMApAQCAtNDAsMTEgKzQwLDExIEBACiAJYWNsb2NhbC90
Y3Atd3JhcHBlcnMubTQKIAogaW5zdGFsbC1kYXRhLWhvb2s6Ci0JaWYgWyAh
IC1kICQoc3RhdGVkaXIpIF07IHRoZW4gbWtkaXIgLXAgJChzdGF0ZWRpcik7
IGZpCi0JdG91Y2ggJChzdGF0ZWRpcikveHRhYjsgY2htb2QgNjQ0ICQoc3Rh
dGVkaXIpL3h0YWIKLQl0b3VjaCAkKHN0YXRlZGlyKS9ldGFiOyBjaG1vZCA2
NDQgJChzdGF0ZWRpcikvZXRhYgotCXRvdWNoICQoc3RhdGVkaXIpL3JtdGFi
OyBjaG1vZCA2NDQgJChzdGF0ZWRpcikvcm10YWIKLQlta2RpciAtcCAkKHN0
YXRlZGlyKS9zbSAkKHN0YXRlZGlyKS9zbS5iYWsKLQl0b3VjaCAkKHN0YXRl
ZGlyKS9zdGF0ZQotCWNobW9kIGdvLXJ3eCAkKHN0YXRlZGlyKS9zbSAkKHN0
YXRlZGlyKS9zbS5iYWsgJChzdGF0ZWRpcikvc3RhdGUKLQljaG93biAkKHN0
YXRkdXNlcikgJChzdGF0ZWRpcikvc20gJChzdGF0ZWRpcikvc20uYmFrICQo
c3RhdGVkaXIpL3N0YXRlCisJaWYgWyAhIC1kICQoREVTVERJUikvJChzdGF0
ZWRpcikgXTsgdGhlbiBta2RpciAtcCAgJChERVNURElSKS8kKHN0YXRlZGly
KTsgZmkKKwl0b3VjaCAgJChERVNURElSKS8kKHN0YXRlZGlyKS94dGFiOyBj
aG1vZCA2NDQgICQoREVTVERJUikvJChzdGF0ZWRpcikveHRhYgorCXRvdWNo
ICAkKERFU1RESVIpLyQoc3RhdGVkaXIpL2V0YWI7IGNobW9kIDY0NCAgJChE
RVNURElSKS8kKHN0YXRlZGlyKS9ldGFiCisJdG91Y2ggICQoREVTVERJUikv
JChzdGF0ZWRpcikvcm10YWI7IGNobW9kIDY0NCAgJChERVNURElSKS8kKHN0
YXRlZGlyKS9ybXRhYgorCW1rZGlyIC1wICAkKERFU1RESVIpLyQoc3RhdGVk
aXIpL3NtICAkKERFU1RESVIpLyQoc3RhdGVkaXIpL3NtLmJhaworCXRvdWNo
ICAkKERFU1RESVIpLyQoc3RhdGVkaXIpL3N0YXRlCisJY2htb2QgZ28tcnd4
ICAkKERFU1RESVIpLyQoc3RhdGVkaXIpL3NtICAkKERFU1RESVIpLyQoc3Rh
dGVkaXIpL3NtLmJhayAgJChERVNURElSKS8kKHN0YXRlZGlyKS9zdGF0ZQor
CWNob3duICAkKHN0YXRkdXNlcikgICQoREVTVERJUikvJChzdGF0ZWRpcikv
c20gICQoREVTVERJUikvJChzdGF0ZWRpcikvc20uYmFrICAkKERFU1RESVIp
LyQoc3RhdGVkaXIpL3N0YXRlCg==

--0-420900565-1136379468=:23661--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

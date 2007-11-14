From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [PATCH] 2.6.24-rc2-mm1 - Build fails - in nsfd/vfs.c
Date: Wed, 14 Nov 2007 10:42:47 +0530
Message-ID: <473A83CF.90104@linux.vnet.ibm.com>
References: <20071114044904.GA12453@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: akpm@linux-foundation.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, apw@shadowen.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsAb6-00051G-Ql
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 21:15:33 -0800
Received: from e23smtp04.au.ibm.com ([202.81.18.173])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsAb9-00040V-4I
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 21:15:36 -0800
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id lAE5D9pk008427
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 16:13:09 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id
	lAE5GoAD257852
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 16:16:50 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	lAE5Cwbt021804
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 16:12:58 +1100
In-Reply-To: <20071114044904.GA12453@linux.vnet.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

S2FtYWxlc2ggQmFidWxhbCB3cm90ZToKPiBIaSBBbmRyZXcsCj4gCj4gVGhlIEtlcm5lbCBidWls
ZCBmYWlscywgd2l0aCBlcnJvcgo+IAo+ICAgQ0MgICAgICBmcy9uZnNkL3Zmcy5vCj4gZnMvbmZz
ZC92ZnMuYzogSW4gZnVuY3Rpb24g4oCYbmZzZF9yZW5hbWXigJk6Cj4gZnMvbmZzZC92ZnMuYzox
Njk1OiBlcnJvcjogcmVxdWVzdCBmb3IgbWVtYmVyIOKAmG1udOKAmSBpbiBzb21ldGhpbmcgbm90
IGEgc3RydWN0dXJlIG9yIHVuaW9uCj4gbWFrZVsyXTogKioqIFtmcy9uZnNkL3Zmcy5vXSBFcnJv
ciAxCj4gbWFrZVsxXTogKioqIFtmcy9uZnNkXSBFcnJvciAyCj4gbWFrZTogKioqIFtmc10gRXJy
b3IgMgo+IAo+IFNpZ25lZC1vZmYtYnk6IEthbWFsZXNoIEJhYnVsYWwgPGthbWFsZXNoQGxpbnV4
LnZuZXQuaWJtLmNvbT4KPiAtLQo+IC0tLSBsaW51eC0yLjYuMjQtcmMyL2ZzL25mc2QvdmZzLmMJ
MjAwNy0xMS0xMyAyMjoxNjoxOC4wMDAwMDAwMDAgLTA1MDAKPiArKysgbGludXgtMi42LjI0LXJj
Mi9mcy9uZnNkL352ZnMuYwkyMDA3LTExLTEzIDIzOjEwOjE4LjAwMDAwMDAwMCAtMDUwMAo+IEBA
IC0xNjkyLDcgKzE2OTIsNyBAQCBuZnNkX3JlbmFtZShzdHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3RwLCBz
dHJ1Cj4gIAkJaWYgKCFob3N0X2VycikKPiAgCQkJaG9zdF9lcnIgPSBuZnNkX3N5bmNfZGlyKGZk
ZW50cnkpOwo+ICAJfQo+IC0JbW50X2Ryb3Bfd3JpdGUoZmZocC0+ZmhfZXhwb3J0LT5leF9wYXRo
Lm1udCk7Cj4gKwltbnRfZHJvcF93cml0ZShmZmhwLT5maF9leHBvcnQtPmV4X21udCk7Cj4gCj4g
ICBvdXRfZHB1dF9uZXc6Cj4gIAlkcHV0KG5kZW50cnkpOwo+IApTb3JyeSwgZm9yIHRoZSByZXBv
cnQsIGl0cyBjb21waWxlcyBmaW5lLCBteSBib3ggaGFkIHRoZSB3cm9uZwptbSBwYXRjaGVzLgoK
LS0gClRoYW5rcyAmIFJlZ2FyZHMsCkthbWFsZXNoIEJhYnVsYWwsCkxpbnV4IFRlY2hub2xvZ3kg
Q2VudGVyLApJQk0sIElTVEwuCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClRoaXMgU0YubmV0IGVtYWlsIGlz
IHNwb25zb3JlZCBieTogU3BsdW5rIEluYy4KU3RpbGwgZ3JlcHBpbmcgdGhyb3VnaCBsb2cgZmls
ZXMgdG8gZmluZCBwcm9ibGVtcz8gIFN0b3AuCk5vdyBTZWFyY2ggbG9nIGV2ZW50cyBhbmQgY29u
ZmlndXJhdGlvbiBmaWxlcyB1c2luZyBBSkFYIGFuZCBhIGJyb3dzZXIuCkRvd25sb2FkIHlvdXIg
RlJFRSBjb3B5IG9mIFNwbHVuayBub3cgPj4gaHR0cDovL2dldC5zcGx1bmsuY29tLwpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0g
IE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQv
bGlzdHMvbGlzdGluZm8vbmZzCg==

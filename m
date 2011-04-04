Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:12336 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753731Ab1DDIDC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 04:03:02 -0400
From: "Finney, Sean" <Sean.Finney@sonyericsson.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 4 Apr 2011 10:02:59 +0200
Subject: Fixes for NFS in environments with large group memberships
Message-ID: <A50602A820F61543B29992A418BB321B66E18F8A4A@seldmbx01.corpusers.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

SGkgVGhlcmUhCgpMYXN0IHdlZWsgSSBmaXJlZCBvZmYgYSBjb3VwbGUgcGF0Y2hlcyB0byB0aGlz
IGxpc3QgYW5kIGluIGhpbmRzaWdodCBJCnJlYWxpemUgdGhhdCBJIG1pZ2h0IG5vdCBoYXZlIGJl
ZW4gdG90YWxseSBjbGVhciBmb3IgdGhlIG1vdGl2YXRpb24KYmVoaW5kIHRoZSBwYXRjaGVzOgoK
W1BBVENIXSBVc2UgYSBuYW1lZCBjb25zdGFudCBmb3IgbWF4IG51bWJlciBvZiBtYW5hZ2VkIGdy
b3VwcywgYW5kIGluYwpbUEFUQ0hdIEluY3JlYXNlIHRoZSBkZWZhdWx0IGJ1ZmZlciBzaXplIGZv
ciBjYWNoZWxpc3QgY2hhbm5lbCBmaWxlcy4KClNpbmNlIG5vYm9keSBoYXMgcmV2aWV3ZWQgdGhl
bSB5ZXQsIEkgdGhvdWdodCBJJ2QgbWFrZSBpdCBjbGVhciB0aGF0CnRoZXNlIGNoYW5nZXMgKG9y
IHNvbWV0aGluZyBhbG9uZyBzdWNoIGxpbmVzKSBhcmUgcmVxdWlyZWQgZm9yIE5GUwphY2Nlc3Mg
dG8gbW91bnRwb2ludHMgd2hlbiB1c2VycyBhcmUgaW4gbGFyZ2Vpc2ggKD4xMDApIG51bWJlcnMg
b2YKZ3JvdXBzLiAgVGhlcmUgYXJlIGFjdHVhbGx5IHR3byBwcm9ibGVtczoKCiogSGFyZC1jb2Rl
ZCBsaW1pdCBmb3IgZ3JvdXAgbWVtYmVyc2hpcCBhdCAxMDAgZ3JvdXBzIGluIG1vdW50ZCBzb3Vy
Y2UKKiBMYXJnZSBzZXJ2ZXItc2lkZSBwcm9jZnMgd3JpdGVzIGFyZSBzcGxpdCBpbnRvIG11bGl0
cGxlIHdyaXRlcyBkdWUgdG8Kc3RkaW8gYnVmZmVyaW5nIGluIG1vdW50ZCBhbmQgc3ZjZ3NzZCBz
b3VyY2VzLCByZXN1bHRpbmcgaW4gY2xpZW50CmhhbmdzLgoKVGhlIHBhdGNoZXMgaW4gcXVlc3Rp
b24gc29sdmUgdGhpcyBpbiBhcyBub24taW50cnVzaXZlIGEgbWFubmVyIGFzCnBvc3NpYmxlLCB0
aG91Z2ggSSdtIG9mIGNvdXJzZSBvcGVuIHRvIGNoYW5naW5nIHRoaW5ncyB1cCBpZiB5b3UgZmVl
bCBpdApzaG91bGQgYmUgZG9uZSBvdGhlcndpc2UuICBTbyBwbGVhc2UgbGV0IG1lIGtub3cgd2hh
dCB5b3UgdGhpbmssIG9yIGlmCml0IHdvdWxkIGJlIGJldHRlciBmb3IgbWUgdG8gZmlyc3QgZ28g
YW5kIG9wZW4gYSBidWcsIHN0YXJ0IGEKZGlzY3Vzc2lvbiwgZXRjLgoKClRoYW5rcywKU2VhbiAK
Tu+/ve+/ve+/ve+/ve+/vXLvv73vv71577+977+977+9Yu+/vVjvv73vv73Hp3bvv71e77+9Kd66
ey5u77+9K++/ve+/ve+/ve+/vXvvv73vv73vv70i77+977+9Xm7vv71y77+977+977+9eu+/vRrv
v73vv71o77+977+977+977+9Ju+/ve+/vR7vv71H77+977+977+9aO+/vQMo77+96ZqO77+93aJq
Iu+/ve+/vRrvv70bbe+/ve+/ve+/ve+/ve+/vXrvv73elu+/ve+/ve+/vWbvv73vv73vv71o77+9
77+977+9fu+/vW3vv70=

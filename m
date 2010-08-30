Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:53687 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab0H3N5i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 09:57:38 -0400
Message-ID: <4C7BB8C1.40906@mudrichsystems.com>
Date: Mon, 30 Aug 2010 15:57:21 +0200
From: David Mudrich <dmudrich@mudrichsystems.com>
To: sfjro@users.sourceforge.net, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: Re: AUFS triggers Kernel BUG() in nfs_do_writepage (write.c:276)
References: <4C7960EE.6060304@mudrichsystems.com> <3217.1283139187@jrobl> <4C7B53F3.8010709@mudrichsystems.com> <7041.1283154060@jrobl>
In-Reply-To: <7041.1283154060@jrobl>
Content-Type: multipart/mixed;
 boundary="------------080805060601010600000101"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080805060601010600000101
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

  Am 30.08.2010 09:41, schrieb sfjro@users.sourceforge.net:
> David Mudrich:
>> I attached the information you asked for. It seems difficult to have a
>> realistic test without AUFS, as it is mounted at the root directory.
> Thanx.
> It is difficult for me too.
> Although I am not confident, these commits (from latest mainline) are
> worth to try. If you have no way other than this, you should try.
>
>
> J. R. Okajima
>
Hello,

I applied the patch, same issue.
I attached dmesg | tail -n 50.

I just tried nfsvers=2 and it works.
The problem must be connected with nfs3 writeback.

A copy of this mail goes to the linux-nfs list, maybe they can help to 
further narrow this.


Regards

David Mudrich

--------------080805060601010600000101
Content-Type: text/plain;
 name="log.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="log.txt"

dWRldjogc3RhcnRpbmcgdmVyc2lvbiAxNTEKZXRoMTogbm8gSVB2NiByb3V0ZXJzIHByZXNlbnQK
ZXRoMDogbm8gSVB2NiByb3V0ZXJzIHByZXNlbnQKLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0t
LS0tLS0tLS0tCmtlcm5lbCBCVUcgYXQgZnMvbmZzL3dyaXRlLmM6Mjc2IQppbnZhbGlkIG9wY29k
ZTogMDAwMCBbIzFdIFNNUCAKbGFzdCBzeXNmcyBmaWxlOiAvc3lzL2RldmljZXMvdmlydGlvLXBj
aS92aXJ0aW8yL25ldC9ldGgwL2lmaW5kZXgKQ1BVIDAgCk1vZHVsZXMgbGlua2VkIGluOgoKUGlk
OiAyMDY5LCBjb21tOiBucy1zbGFwZCBOb3QgdGFpbnRlZCAyLjYuMzUuMy54ODZfNjQuYXVmcyAj
NSAvQm9jaHMKUklQOiAwMDEwOls8ZmZmZmZmZmY4MTFiNjZhMT5dICBbPGZmZmZmZmZmODExYjY2
YTE+XSBuZnNfZG9fd3JpdGVwYWdlKzB4MjAxLzB4MjEwClJTUDogMDAxODpmZmZmODgwMDdjYThi
YmY4ICBFRkxBR1M6IDAwMDEwMjAyClJBWDogMDAwMDAwMDAwMDAwMDAwMSBSQlg6IGZmZmY4ODAw
Mzc4Y2I5MDAgUkNYOiAwMDAwMDAwMDAwMDAwMDAxClJEWDogMDAwMDAwMDAwMDAwMmNkMCBSU0k6
IDAwMDAwMDAwMDAwMDAwMGIgUkRJOiBmZmZmODgwMDM3OGYwNDAwClJCUDogZmZmZmVhMDAwMTMx
ZjcyOCBSMDg6IGZmZmY4ODAwN2NhOGJiMDggUjA5OiAwMDAwMDAwMDAwMDAwMDAwClIxMDogMDAw
MDAwMDBmZmZmZmZmZiBSMTE6IGZmZmY4ODAwNTg5MGJlODggUjEyOiAwMDAwMDAwMDAwMDAwMDAw
ClIxMzogMDAwMDAwMDAwMDAwMDAwMCBSMTQ6IGZmZmY4ODAwN2NhOGJkOTggUjE1OiBmZmZmODgw
MDdjYThiZTE4CkZTOiAgMDAwMDdmZTBlYzUxYTdjMCgwMDAwKSBHUzpmZmZmODgwMDAxODAwMDAw
KDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAKQ1M6ICAwMDEwIERTOiAwMDAwIEVTOiAwMDAw
IENSMDogMDAwMDAwMDA4MDA1MDAzYgpDUjI6IDAwMDA3ZmUwZWQxYmUwMDggQ1IzOiAwMDAwMDAw
MDdjNzI0MDAwIENSNDogMDAwMDAwMDAwMDAwMDZiMApEUjA6IDAwMDAwMDAwMDAwMDAwMDAgRFIx
OiAwMDAwMDAwMDAwMDAwMDAwIERSMjogMDAwMDAwMDAwMDAwMDAwMApEUjM6IDAwMDAwMDAwMDAw
MDAwMDAgRFI2OiAwMDAwMDAwMGZmZmYwZmYwIERSNzogMDAwMDAwMDAwMDAwMDQwMApQcm9jZXNz
IG5zLXNsYXBkIChwaWQ6IDIwNjksIHRocmVhZGluZm8gZmZmZjg4MDA3Y2E4YTAwMCwgdGFzayBm
ZmZmODgwMDdjNDRjMDAwKQpTdGFjazoKIGZmZmZmZmZmODExZGY3YzAgZmZmZmZmZmY4MTBhN2Rk
YSBmZmZmODgwMDdjNDRjMDAwIDAwMDAwMDAwMDAwMDAwMDAKPDA+IDAwMDAwMDAwMDAwMDAwMDIg
ZmZmZmVhMDAwMTMxZjcyOCBmZmZmODgwMDU4ODlkOGEwIDAwMDAwMDAwMDAwMDAyMGEKPDA+IGZm
ZmZlYTAwMDEzMWY3MjggMDAwMDAwMDAwMDAwMDAwMCBmZmZmODgwMDdjYThiY2QwIGZmZmZmZmZm
ODExYjZjZDYKQ2FsbCBUcmFjZToKIFs8ZmZmZmZmZmY4MTFkZjdjMD5dID8gYXVfZG9fZmx1c2hf
bm9uZGlyKzB4MC8weDMwCiBbPGZmZmZmZmZmODEwYTdkZGE+XSA/IGZpbmRfZ2V0X3BhZ2VzX3Rh
ZysweDNhLzB4MTEwCiBbPGZmZmZmZmZmODExYjZjZDY+XSA/IG5mc193cml0ZXBhZ2VzX2NhbGxi
YWNrKzB4MTYvMHg0MAogWzxmZmZmZmZmZjgxMWRmN2MwPl0gPyBhdV9kb19mbHVzaF9ub25kaXIr
MHgwLzB4MzAKIFs8ZmZmZmZmZmY4MTBhZjRjMT5dID8gd3JpdGVfY2FjaGVfcGFnZXMrMHgxYTEv
MHgzNzAKIFs8ZmZmZmZmZmY4MTFiNmNjMD5dID8gbmZzX3dyaXRlcGFnZXNfY2FsbGJhY2srMHgw
LzB4NDAKIFs8ZmZmZmZmZmY4MTFkZjdjMD5dID8gYXVfZG9fZmx1c2hfbm9uZGlyKzB4MC8weDMw
CiBbPGZmZmZmZmZmODExYjZjMzY+XSA/IG5mc193cml0ZXBhZ2VzKzB4YTYvMHgxMzAKIFs8ZmZm
ZmZmZmY4MTFiN2ZiMD5dID8gbmZzX2ZsdXNoX29uZSsweDAvMHhlMAogWzxmZmZmZmZmZjgxMGE5
MTU5Pl0gPyBfX2ZpbGVtYXBfZmRhdGF3cml0ZV9yYW5nZSsweDQ5LzB4NTAKIFs8ZmZmZmZmZmY4
MTBhOTFiYT5dID8gZmlsZW1hcF93cml0ZV9hbmRfd2FpdF9yYW5nZSsweDVhLzB4ODAKIFs8ZmZm
ZmZmZmY4MTEwNjFkYj5dID8gdmZzX2ZzeW5jX3JhbmdlKzB4NWIvMHhhMAogWzxmZmZmZmZmZjgx
MWQ0Y2U1Pl0gPyB2ZnN1Yl9mbHVzaCsweDI1LzB4NjAKIFs8ZmZmZmZmZmY4MTFkZGZiMD5dID8g
YXVfZG9fZmx1c2grMHhiMC8weDE2MAogWzxmZmZmZmZmZjgxMGUwMDc1Pl0gPyBmaWxwX2Nsb3Nl
KzB4MzUvMHg5MAogWzxmZmZmZmZmZjgxMGUwMTdmPl0gPyBzeXNfY2xvc2UrMHhhZi8weDEyMAog
WzxmZmZmZmZmZjgxMDI5NjAyPl0gPyBzeXN0ZW1fY2FsbF9mYXN0cGF0aCsweDE2LzB4MWIKQ29k
ZTogZmYgZmYgNDggNjMgZDggZTkgMGMgZmYgZmYgZmYgMGYgMGIgZWIgZmUgMGYgMWYgNDAgMDAg
NDggODMgYzcgNDggMzEgZjYgZTggZmQgNGIgZjAgZmYgZTkgNjkgZmYgZmYgZmYgNDggOGIgNDUg
MTAgZTkgMzYgZmYgZmYgZmYgPDBmPiAwYiBlYiBmZSA2NiA2NiAyZSAwZiAxZiA4NCAwMCAwMCAw
MCAwMCAwMCA0OCA4MyBlYyA2OCBiYSAxNCAKUklQICBbPGZmZmZmZmZmODExYjY2YTE+XSBuZnNf
ZG9fd3JpdGVwYWdlKzB4MjAxLzB4MjEwCiBSU1AgPGZmZmY4ODAwN2NhOGJiZjg+Ci0tLVsgZW5k
IHRyYWNlIGJiYWY3NzZlNzczYjRmMjUgXS0tLQo=

--------------080805060601010600000101--

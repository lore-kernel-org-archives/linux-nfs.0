Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44982 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934264Ab1KJPiR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 10:38:17 -0500
Received: by vcbf1 with SMTP id f1so2480255vcb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 07:38:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
References: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 10 Nov 2011 23:37:51 +0800
Message-ID: <CA+a=Yy6cL1JsHh7+zpOoUC=QHBCPpub5HP4RAqT+2n_iOOseeg@mail.gmail.com>
Subject: Re: [PATCH-v2 0/7] pnfsblock cleanup and fixes
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com
Content-Type: multipart/mixed; boundary=bcaec5196a65737fe004b16331bc
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--bcaec5196a65737fe004b16331bc
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 10, 2011 at 11:25 PM, Peng Tao <bergwolf@gmail.com> wrote:
> Hi, Trond and Benny,
>
> These are updated v2 of the pnfsblock patches and all Benny's comments ar=
e addressed.
>
> Thanks,
> Tao
>
> Peng Tao (8):
> =C2=A0pnfsblock: cleanup bl_mark_sectors_init
> =C2=A0pnfsblock: acquire im_lock in _preload_range
Just checked. This one is dropped by vger again... even thought I
resent it once again separately.

So I have to attach it here....

Thanks,
Tao

> =C2=A0pnfsblock: move find lock page logic out of bl_write_pagelist
> =C2=A0pnfsblock: set read/write tk_status to pnfs_error
> =C2=A0pnfsblock: remove rpc_call_ops from struct parallel_io
> =C2=A0pnfsblock: clean up _add_entry
> =C2=A0pnfsblock: alloc short extent before submit bio
> =C2=A0pnfsblock: release lock when freeing block_dev
>
> =C2=A0fs/nfs/blocklayout/blocklayout.c | =C2=A0176 ++++++++++++++++++++++=
+++-------------
> =C2=A0fs/nfs/blocklayout/blocklayout.h | =C2=A0 12 ++-
> =C2=A0fs/nfs/blocklayout/extents.c =C2=A0 =C2=A0 | =C2=A0157 ++++++++++++=
++--------------------
> =C2=A03 files changed, 192 insertions(+), 153 deletions(-)
>
>



--=20
Thanks,
-Bergwolf

--bcaec5196a65737fe004b16331bc
Content-Type: application/octet-stream;
	name="0002-pnfsblock-acquire-im_lock-in-_preload_range.patch"
Content-Disposition: attachment;
	filename="0002-pnfsblock-acquire-im_lock-in-_preload_range.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gutx6vne0

RnJvbSA2YjkxOWUwZDk3ODQ2ZGUxMDRiYjQ0ODE1NDFkOGIxZDA2MTJhOGE3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQZW5nIFRhbyA8YmVyZ3dvbGZAZ21haWwuY29tPgpEYXRlOiBX
ZWQsIDIgTm92IDIwMTEgMDE6MTE6MTQgLTA0MDAKU3ViamVjdDogW1BBVENILXYyIDIvN10gcG5m
c2Jsb2NrOiBhY3F1aXJlIGltX2xvY2sgaW4gX3ByZWxvYWRfcmFuZ2UKCldoZW4gY2FsbGluZyBf
YWRkX2VudHJ5LCB3ZSBzaG91bGQgdGFrZSB0aGUgaW1fbG9jayB0byBwcm90ZWN0CmFnYWlucyBv
dGhlciBtb2RpZmllcnMuCgpDYzogc3RhYmxlQGtlcm5lbC5vcmcgWzMuMV0KU2lnbmVkLW9mZi1i
eTogUGVuZyBUYW8gPHBlbmdfdGFvQGVtYy5jb20+Ci0tLQogZnMvbmZzL2Jsb2NrbGF5b3V0L2V4
dGVudHMuYyB8ICAgMTEgKysrKysrLS0tLS0KIDEgZmlsZXMgY2hhbmdlZCwgNiBpbnNlcnRpb25z
KCspLCA1IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2ZzL25mcy9ibG9ja2xheW91dC9leHRl
bnRzLmMgYi9mcy9uZnMvYmxvY2tsYXlvdXQvZXh0ZW50cy5jCmluZGV4IDBmYzEzMjEuLmYzODM1
MjQgMTAwNjQ0Ci0tLSBhL2ZzL25mcy9ibG9ja2xheW91dC9leHRlbnRzLmMKKysrIGIvZnMvbmZz
L2Jsb2NrbGF5b3V0L2V4dGVudHMuYwpAQCAtMTM5LDExICsxMzksMTMgQEAgc3RhdGljIGludCBf
c2V0X3JhbmdlKHN0cnVjdCBteV90cmVlICp0cmVlLCBpbnQzMl90IHRhZywgdTY0IHMsIHU2NCBs
ZW5ndGgpCiB9CiAKIC8qIEVuc3VyZSB0aGF0IGZ1dHVyZSBvcGVyYXRpb25zIG9uIGdpdmVuIHJh
bmdlIG9mIHRyZWUgd2lsbCBub3QgbWFsbG9jICovCi1zdGF0aWMgaW50IF9wcmVsb2FkX3Jhbmdl
KHN0cnVjdCBteV90cmVlICp0cmVlLCB1NjQgb2Zmc2V0LCB1NjQgbGVuZ3RoKQorc3RhdGljIGlu
dCBfcHJlbG9hZF9yYW5nZShzdHJ1Y3QgcG5mc19pbnZhbF9tYXJraW5ncyAqbWFya3MsCisJCXU2
NCBvZmZzZXQsIHU2NCBsZW5ndGgpCiB7CiAJdTY0IHN0YXJ0LCBlbmQsIHM7CiAJaW50IGNvdW50
LCBpLCB1c2VkID0gMCwgc3RhdHVzID0gLUVOT01FTTsKIAlzdHJ1Y3QgcG5mc19pbnZhbF90cmFj
a2luZyAqKnN0b3JhZ2U7CisJc3RydWN0IG15X3RyZWUgICp0cmVlID0gJm1hcmtzLT5pbV90cmVl
OwogCiAJZHByaW50aygiJXMoJWxsdSwgJWxsdSkgZW50ZXJcbiIsIF9fZnVuY19fLCBvZmZzZXQs
IGxlbmd0aCk7CiAJc3RhcnQgPSBub3JtYWxpemUob2Zmc2V0LCB0cmVlLT5tdHRfc3RlcF9zaXpl
KTsKQEAgLTE2MSwxMiArMTYzLDExIEBAIHN0YXRpYyBpbnQgX3ByZWxvYWRfcmFuZ2Uoc3RydWN0
IG15X3RyZWUgKnRyZWUsIHU2NCBvZmZzZXQsIHU2NCBsZW5ndGgpCiAJCQlnb3RvIG91dF9jbGVh
bnVwOwogCX0KIAotCS8qIE5vdyBuZWVkIGxvY2sgLSBIT1c/Pz8gKi8KLQorCXNwaW5fbG9jaygm
bWFya3MtPmltX2xvY2spOwogCWZvciAocyA9IHN0YXJ0OyBzIDwgZW5kOyBzICs9IHRyZWUtPm10
dF9zdGVwX3NpemUpCiAJCXVzZWQgKz0gX2FkZF9lbnRyeSh0cmVlLCBzLCBJTlRFUk5BTF9FWElT
VFMsIHN0b3JhZ2VbdXNlZF0pOworCXNwaW5fdW5sb2NrKCZtYXJrcy0+aW1fbG9jayk7CiAKLQkv
KiBVbmxvY2sgLSBIT1c/Pz8gKi8KIAlzdGF0dXMgPSAwOwogCiAgb3V0X2NsZWFudXA6CkBAIC0y
NDYsNyArMjQ3LDcgQEAgaW50IGJsX21hcmtfc2VjdG9yc19pbml0KHN0cnVjdCBwbmZzX2ludmFs
X21hcmtpbmdzICptYXJrcywKIAogCXN0YXJ0ID0gbm9ybWFsaXplKG9mZnNldCwgbWFya3MtPmlt
X2Jsb2NrX3NpemUpOwogCWVuZCA9IG5vcm1hbGl6ZV91cChvZmZzZXQgKyBsZW5ndGgsIG1hcmtz
LT5pbV9ibG9ja19zaXplKTsKLQlpZiAoX3ByZWxvYWRfcmFuZ2UoJm1hcmtzLT5pbV90cmVlLCBz
dGFydCwgZW5kIC0gc3RhcnQpKQorCWlmIChfcHJlbG9hZF9yYW5nZShtYXJrcywgc3RhcnQsIGVu
ZCAtIHN0YXJ0KSkKIAkJZ290byBvdXRlcnI7CiAKIAlzcGluX2xvY2soJm1hcmtzLT5pbV9sb2Nr
KTsKLS0gCjEuNy4xLjI2Mi5nNWVmM2QKCg==
--bcaec5196a65737fe004b16331bc--

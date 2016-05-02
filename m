Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:34843 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbcEBUIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 16:08:05 -0400
MIME-Version: 1.0
In-Reply-To: <20160502102248.18755.qmail@ns.horizon.com>
References: <20160502102016.17936.qmail@ns.horizon.com>
	<20160502102248.18755.qmail@ns.horizon.com>
Date: Mon, 2 May 2016 13:08:03 -0700
Message-ID: <CA+55aFyPMrAWqMaA013ZQA0TULtdTXbUh4rgUurMLu40TastuA@mail.gmail.com>
Subject: Re: [PATCH 2/2] <linux/hash.h>: Fix hash_64()'s horrible collision problem
From: Linus Torvalds <torvalds@linux-foundation.org>
To: George Spelvin <linux@horizon.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Bruce Fields <bfields@fieldses.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Rik van Riel <riel@redhat.com>
Content-Type: multipart/mixed; boundary=047d7bd7528cd8c0ee0531e18c2b
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--047d7bd7528cd8c0ee0531e18c2b
Content-Type: text/plain; charset=UTF-8

On Mon, May 2, 2016 at 3:22 AM, George Spelvin <linux@horizon.com> wrote:
> hash_64() was using a low-bit-weight multiplier, which resulted in
> very bad mixing of the high bits of the input.  In particular,
> page-aligned pointers (low 12 bits not used) were a disaster,

So I did just a minimal for fro 4.6 (and back-porting), which took
just the constants and made _only_ the 64-bit architevture case use
this improved constant for hash_64.

In other words, people who use "hash_long()" or use "hash_64()" on
64-bit architectures will get the improvements, but if you use
hash_64() on a 32-bit architecture you'll conteinue to see the old
behavior.

Quite frankly, looking at some of the explicit hash_64() users, they
seem to be a big dubious anyway. And it won't make things *worse* for
them.

So that simple "just use multiplication unconditionally on 64-bit, and
use the better constant" should fix the actual _practical_ problems
that we've seen. And it shouldn't have any negative consequences,
since as you say, 64-bit architectures universally do have a
multiplier.

The bigger changes will have to be for 4.7 by now, I think.

                     Linus

--047d7bd7528cd8c0ee0531e18c2b
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_inqfu3kd0

RnJvbSA2ODlkZTFkNmNhOTViM2I1YmQ4ZWU0NDY4NjNiZjgxYTQ4ODNlYTI1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBMaW51cyBUb3J2YWxkcyA8dG9ydmFsZHNAbGludXgtZm91bmRh
dGlvbi5vcmc+CkRhdGU6IE1vbiwgMiBNYXkgMjAxNiAxMjo0Njo0MiAtMDcwMApTdWJqZWN0OiBb
UEFUQ0hdIE1pbmltYWwgZml4LXVwIG9mIGJhZCBoYXNoaW5nIGJlaGF2aW9yIG9mIGhhc2hfNjQo
KQoKVGhpcyBpcyBhIGZhaXJseSBtaW5pbWFsIGZpeHVwIHRvIHRoZSBob3JyaWJseSBiYWQgYmVo
YXZpb3Igb2YgaGFzaF82NCgpCndpdGggY2VydGFpbiBpbnB1dCBwYXR0ZXJucy4KCkluIHBhcnRp
Y3VsYXIsIGJlY2F1c2UgdGhlIG11bHRpcGxpY2F0aXZlIHZhbHVlIHVzZWQgZm9yIHRoZSA2NC1i
aXQgaGFzaAp3YXMgaW50ZW50aW9uYWxseSBiaXQtc3BhcnNlIChzbyB0aGF0IHRoZSBtdWx0aXBs
eSBjb3VsZCBiZSBkb25lIHdpdGgKc2hpZnRzIGFuZCBhZGRzIG9uIGFyY2hpdGVjdHVyZXMgd2l0
aG91dCBoYXJkd2FyZSBtdWx0aXBsaWVycyksIHNvbWUKYml0cyBkaWQgbm90IGdldCBzcHJlYWQg
b3V0IHZlcnkgbXVjaC4gIEluIHBhcnRpY3VsYXIsIGNlcnRhaW4gZmFpcmx5CmNvbW1vbiBiaXQg
cmFuZ2VzIGluIHRoZSBpbnB1dCAocm91Z2hseSBiaXRzIDEyLTIwOiBjb21tb25seSB3aXRoIHRo
ZQptb3N0IGluZm9ybWF0aW9uIGluIHRoZW0gd2hlbiB5b3UgaGFzaCB0aGluZ3MgbGlrZSBieXRl
IG9mZnNldHMgaW4gZmlsZXMKb3IgbWVtb3J5IHRoYXQgaGF2ZSBibG9jayBmYWN0b3JzIHRoYXQg
bWVhbiB0aGF0IHRoZSBsb3cgYml0cyBhcmUgb2Z0ZW4KemVybykgd291bGQgbm90IG5lY2Vzc2Fy
aWx5IHNob3cgdXAgbXVjaCBpbiB0aGUgcmVzdWx0LgoKVGhlcmUncyBhIGJpZ2dlciBwYXRjaC1z
ZXJpZXMgYnJld2luZyB0byBmaXggdXAgdGhpbmdzIG1vcmUgY29tcGxldGVseSwKYnV0IHRoaXMg
aXMgdGhlIGZhaXJseSBtaW5pbWFsIGZpeCBmb3IgdGhlIDY0LWJpdCBoYXNoaW5nIHByb2JsZW0u
ICBJdApzaW1wbHkgcGlja3MgYSBtdWNoIGJldHRlciBjb25zdGFudCBtdWx0aXBsaWVyLCBzcHJl
YWRpbmcgdGhlIGJpdHMgb3V0IGEKbG90IGJldHRlci4KCk5PVEUhIEZvciAzMi1iaXQgYXJjaGl0
ZWN0dXJlcywgdGhlIGJhZCBvbGQgaGFzaF82NCgpIHJlbWFpbnMgdGhlIHNhbWUKZm9yIG5vdywg
c2luY2UgNjQtYml0IG11bHRpcGxpZXMgYXJlIGV4cGVuc2l2ZS4gIFRoZSBiaWdnZXIgaGFzaGlu
ZwpjbGVhbnVwIHdpbGwgcmVwbGFjZSB0aGUgMzItYml0IGNhc2Ugd2l0aCBzb21ldGhpbmcgYmV0
dGVyLgoKVGhlIG5ldyBjb25zdGFudHMgd2VyZSBwaWNrZWQgYnkgR2VvcmdlIFNwZWx2aW4gd2hv
IHdyb3RlIHRoYXQgYmlnZ2VyCmNsZWFudXAgc2VyaWVzLiAgSSBqdXN0IHBpY2tlZCBvdXQgdGhl
IGNvbnN0YW50cyBhbmQgcGFydCBvZiB0aGUgY29tbWVudApmcm9tIHRoYXQgc2VyaWVzLgoKQ2M6
IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcKQ2M6IEdlb3JnZSBTcGVsdmluIDxsaW51eEBob3Jpem9u
LmNvbT4KQ2M6IFRob21hcyBHbGVpeG5lciA8dGdseEBsaW51dHJvbml4LmRlPgpTaWduZWQtb2Zm
LWJ5OiBMaW51cyBUb3J2YWxkcyA8dG9ydmFsZHNAbGludXgtZm91bmRhdGlvbi5vcmc+CgpkaWZm
IC0tZ2l0IGEvaW5jbHVkZS9saW51eC9oYXNoLmggYi9pbmNsdWRlL2xpbnV4L2hhc2guaAppbmRl
eCAxYWZkZTQ3ZTE1MjguLjc5YzUyZmE4MWNhYyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9o
YXNoLmgKKysrIGIvaW5jbHVkZS9saW51eC9oYXNoLmgKQEAgLTMyLDEyICszMiwyOCBAQAogI2Vy
cm9yIFdvcmRzaXplIG5vdCAzMiBvciA2NAogI2VuZGlmCiAKKy8qCisgKiBUaGUgYWJvdmUgcHJp
bWVzIGFyZSBhY3RpdmVseSBiYWQgZm9yIGhhc2hpbmcsIHNpbmNlIHRoZXkgYXJlCisgKiB0b28g
c3BhcnNlLiBUaGUgMzItYml0IG9uZSBpcyBtb3N0bHkgb2ssIHRoZSA2NC1iaXQgb25lIGNhdXNl
cworICogcmVhbCBwcm9ibGVtcy4gQmVzaWRlcywgdGhlICJwcmltZSIgcGFydCBpcyBwb2ludGxl
c3MgZm9yIHRoZQorICogbXVsdGlwbGljYXRpdmUgaGFzaC4KKyAqCisgKiBBbHRob3VnaCBhIHJh
bmRvbSBvZGQgbnVtYmVyIHdpbGwgZG8sIGl0IHR1cm5zIG91dCB0aGF0IHRoZSBnb2xkZW4KKyAq
IHJhdGlvIHBoaSA9IChzcXJ0KDUpLTEpLzIsIG9yIGl0cyBuZWdhdGl2ZSwgaGFzIHBhcnRpY3Vs
YXJseSBuaWNlCisgKiBwcm9wZXJ0aWVzLgorICoKKyAqIFRoZXNlIGFyZSB0aGUgbmVnYXRpdmUs
ICgxIC0gcGhpKSA9IChwaGleMikgPSAoMyAtIHNxcnQoNSkpLzIuCisgKiAoU2VlIEtudXRoIHZv
bCAzLCBzZWN0aW9uIDYuNCwgZXhlcmNpc2UgOS4pCisgKi8KKyNkZWZpbmUgR09MREVOX1JBVElP
XzMyIDB4NjFDODg2NDcKKyNkZWZpbmUgR09MREVOX1JBVElPXzY0IDB4NjFDODg2NDY4MEI1ODNF
QnVsbAorCiBzdGF0aWMgX19hbHdheXNfaW5saW5lIHU2NCBoYXNoXzY0KHU2NCB2YWwsIHVuc2ln
bmVkIGludCBiaXRzKQogewogCXU2NCBoYXNoID0gdmFsOwogCi0jaWYgZGVmaW5lZChDT05GSUdf
QVJDSF9IQVNfRkFTVF9NVUxUSVBMSUVSKSAmJiBCSVRTX1BFUl9MT05HID09IDY0Ci0JaGFzaCA9
IGhhc2ggKiBHT0xERU5fUkFUSU9fUFJJTUVfNjQ7CisjaWYgQklUU19QRVJfTE9ORyA9PSA2NAor
CWhhc2ggPSBoYXNoICogR09MREVOX1JBVElPXzY0OwogI2Vsc2UKIAkvKiAgU2lnaCwgZ2NjIGNh
bid0IG9wdGltaXNlIHRoaXMgYWxvbmUgbGlrZSBpdCBkb2VzIGZvciAzMiBiaXRzLiAqLwogCXU2
NCBuID0gaGFzaDsK
--047d7bd7528cd8c0ee0531e18c2b--

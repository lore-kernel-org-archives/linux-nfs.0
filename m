Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:33163 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbaIHXy7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 19:54:59 -0400
Received: by mail-vc0-f170.google.com with SMTP id hy4so1598249vcb.15
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 16:54:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140828014123.GF18016@ZenIV.linux.org.uk>
References: <1408217806-25877-1-git-send-email-xiyou.wangcong@gmail.com>
	<87ppfvrdux.fsf@x220.int.ebiederm.org>
	<20140828014123.GF18016@ZenIV.linux.org.uk>
Date: Mon, 8 Sep 2014 16:54:57 -0700
Message-ID: <CAHQdGtSkHuw22tLecFmo+aRafMM3CXDME-tU_5xoWLgstEnEZw@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: fix kernel warning when removing proc entry
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dan Aloni <dan@kernelim.com>
Content-Type: multipart/mixed; boundary=089e0122a71ed81a550502968b44
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--089e0122a71ed81a550502968b44
Content-Type: text/plain; charset=UTF-8

On Wed, Aug 27, 2014 at 6:41 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Tue, Aug 19, 2014 at 09:20:38PM -0700, Eric W. Biederman wrote:
>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>
>> > I saw the following kernel warning:
>>
>> Cong thanks for finding and tracking this.  I was clearly asleep at the
>> switch when I was testing my fix to the nfs client code :(
>>
>> I have applied this patch and will push it to Linus after it has a
>> little bit to sit in linux-next.
>
>         Why does that code wank with one-by-one remove_proc_entry(), BTW?
> remove_proc_subtree("nfsfs", net->proc_net) will take care of the whole pile
> just fine, TYVM...  While we are it, there's no need to keep ->proc_nfsfs
> at all - just have it in a local variable in nfs_fs_proc_net_init().

Since nobody sent me an updated version with the remove_proc_subtree
fix, I went ahead and edited the patch myself (see attachment). Cong,
please let me know if you disagree with that change, otherwise, that
will be the final patch sent upstream and Cc: stable # 3.4+.

I'll schedule cleanup patches to make the same changes to the original
nfs_fs_proc_exit() and nfs_fs_proc_init() and to remove (struct
nfs_net)->proc_nfsfs for merging in 3.18.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

--089e0122a71ed81a550502968b44
Content-Type: application/octet-stream;
	name="0001-nfs-fix-kernel-warning-when-removing-proc-entry.patch"
Content-Disposition: attachment;
	filename="0001-nfs-fix-kernel-warning-when-removing-proc-entry.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hzugpdbn0

RnJvbSAyMWU4MTAwMmY5Nzg4YTNhZjU5MTQxNmI2ZGVjNjBkN2I2N2YyZmIyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDb25nIFdhbmcgPHhpeW91Lndhbmdjb25nQGdtYWlsLmNvbT4K
RGF0ZTogTW9uLCA4IFNlcCAyMDE0IDE2OjE3OjU1IC0wNzAwClN1YmplY3Q6IFtQQVRDSF0gbmZz
OiBmaXgga2VybmVsIHdhcm5pbmcgd2hlbiByZW1vdmluZyBwcm9jIGVudHJ5CgpJIHNhdyB0aGUg
Zm9sbG93aW5nIGtlcm5lbCB3YXJuaW5nOgoKWyAxODUyLjMyMTIyMl0gLS0tLS0tLS0tLS0tWyBj
dXQgaGVyZSBdLS0tLS0tLS0tLS0tClsgMTg1Mi4zMjY1MjddIFdBUk5JTkc6IENQVTogMCBQSUQ6
IDExOCBhdCBmcy9wcm9jL2dlbmVyaWMuYzo1MjEgcmVtb3ZlX3Byb2NfZW50cnkrMHgxNTQvMHgx
NmIoKQpbIDE4NTIuMzM1NjMwXSByZW1vdmVfcHJvY19lbnRyeTogcmVtb3Zpbmcgbm9uLWVtcHR5
IGRpcmVjdG9yeSAnZnMvbmZzZnMnLCBsZWFraW5nIGF0IGxlYXN0ICd2b2x1bWVzJwpbIDE4NTIu
MzQ0MDg0XSBDUFU6IDAgUElEOiAxMTggQ29tbToga3dvcmtlci91ODoyIE5vdCB0YWludGVkIDMu
MTYuMCsgIzU0MApbIDE4NTIuMzUwMDM2XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklP
UyBCb2NocyAwMS8wMS8yMDExClsgMTg1Mi4zNTQ5OTJdIFdvcmtxdWV1ZTogbmV0bnMgY2xlYW51
cF9uZXQKWyAxODUyLjM1ODcwMV0gIDAwMDAwMDAwMDAwMDAwMDAgZmZmZjg4MDExNmYyZmJkMCBm
ZmZmZmZmZjgxOWMwM2U5IGZmZmY4ODAxMTZmMmZjMTgKWyAxODUyLjM2NjQ3NF0gIGZmZmY4ODAx
MTZmMmZjMDggZmZmZmZmZmY4MTA3NDRlZSBmZmZmZmZmZjgxMWUwZTZlIGZmZmY4ODAwZDRlOTYy
MzgKWyAxODUyLjM3MzUwN10gIGZmZmZmZmZmODFkYmU2NjUgZmZmZjg4MDBkNDZhNTk0OCAwMDAw
MDAwMDAwMDAwMDA1IGZmZmY4ODAxMTZmMmZjNjgKWyAxODUyLjM4MDIyNF0gQ2FsbCBUcmFjZToK
WyAxODUyLjM4MTk3Nl0gIFs8ZmZmZmZmZmY4MTljMDNlOT5dIGR1bXBfc3RhY2srMHg0ZC8weDY2
ClsgMTg1Mi4zODU0OTVdICBbPGZmZmZmZmZmODEwNzQ0ZWU+XSB3YXJuX3Nsb3dwYXRoX2NvbW1v
bisweDdhLzB4OTMKWyAxODUyLjM4OTg2OV0gIFs8ZmZmZmZmZmY4MTFlMGU2ZT5dID8gcmVtb3Zl
X3Byb2NfZW50cnkrMHgxNTQvMHgxNmIKWyAxODUyLjM5Mzk4N10gIFs8ZmZmZmZmZmY4MTA3NDU3
Yj5dIHdhcm5fc2xvd3BhdGhfZm10KzB4NGMvMHg0ZQpbIDE4NTIuMzk3OTk5XSAgWzxmZmZmZmZm
ZjgxMWUwZTZlPl0gcmVtb3ZlX3Byb2NfZW50cnkrMHgxNTQvMHgxNmIKWyAxODUyLjQwMjAzNF0g
IFs8ZmZmZmZmZmY4MTI5YzczZD5dIG5mc19mc19wcm9jX25ldF9leGl0KzB4NTMvMHg1NgpbIDE4
NTIuNDA2MTM2XSAgWzxmZmZmZmZmZjgxMmExMDNiPl0gbmZzX25ldF9leGl0KzB4MTIvMHgxZApb
IDE4NTIuNDA5Nzc0XSAgWzxmZmZmZmZmZjgxNzg1YmM5Pl0gb3BzX2V4aXRfbGlzdCsweDQ0LzB4
NTUKWyAxODUyLjQxMzUyOV0gIFs8ZmZmZmZmZmY4MTc4NjM4OT5dIGNsZWFudXBfbmV0KzB4ZWUv
MHgxODIKWyAxODUyLjQxNzE5OF0gIFs8ZmZmZmZmZmY4MTA4OGM5ZT5dIHByb2Nlc3Nfb25lX3dv
cmsrMHgyMDkvMHg0MGQKWyAxODUyLjUwMjMyMF0gIFs8ZmZmZmZmZmY4MTA4OGJmNz5dID8gcHJv
Y2Vzc19vbmVfd29yaysweDE2Mi8weDQwZApbIDE4NTIuNTg3NjI5XSAgWzxmZmZmZmZmZjgxMDg5
MGMxPl0gd29ya2VyX3RocmVhZCsweDFmMC8weDJjNwpbIDE4NTIuNjczMjkxXSAgWzxmZmZmZmZm
ZjgxMDg4ZWQxPl0gPyBwcm9jZXNzX3NjaGVkdWxlZF93b3JrcysweDJmLzB4MmYKWyAxODUyLjc1
OTQ3MF0gIFs8ZmZmZmZmZmY4MTA4ZTA3OT5dIGt0aHJlYWQrMHhjOS8weGQxClsgMTg1Mi44NDMw
OTldICBbPGZmZmZmZmZmODEwOTQyN2Y+XSA/IGZpbmlzaF90YXNrX3N3aXRjaCsweDNhLzB4Y2UK
WyAxODUyLjkyNjUxOF0gIFs8ZmZmZmZmZmY4MTA4ZGZiMD5dID8gX19rdGhyZWFkX3BhcmttZSsw
eDYxLzB4NjEKWyAxODUzLjAwODU2NV0gIFs8ZmZmZmZmZmY4MTljYmVhYz5dIHJldF9mcm9tX2Zv
cmsrMHg3Yy8weGIwClsgMTg1My4wNzY0NzddICBbPGZmZmZmZmZmODEwOGRmYjA+XSA/IF9fa3Ro
cmVhZF9wYXJrbWUrMHg2MS8weDYxClsgMTg1My4xNDA2NTNdIC0tLVsgZW5kIHRyYWNlIDY5YzRj
NjYxN2Y3OGUzMmQgXS0tLQoKSXQgbG9va3Mgd3JvbmcgdGhhdCB3ZSBhZGQgIi9wcm9jL25ldC9u
ZnNmcyIgaW4gbmZzX2ZzX3Byb2NfbmV0X2luaXQoKQp3aGlsZSByZW1vdmUgIi9wcm9jL2ZzL25m
c2ZzIiBpbiBuZnNfZnNfcHJvY19uZXRfZXhpdCgpLgoKRml4ZXM6IGNvbW1pdCA2NWIzODg1MWEx
NyAoTkZTOiBGaXggL3Byb2MvZnMvbmZzZnMvc2VydmVycyBhbmQgL3Byb2MvZnMvbmZzZnMvdm9s
dW1lcykKQ2M6IEVyaWMgVy4gQmllZGVybWFuIDxlYmllZGVybUB4bWlzc2lvbi5jb20+CkNjOiBU
cm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20+CkNjOiBEYW4g
QWxvbmkgPGRhbkBrZXJuZWxpbS5jb20+ClNpZ25lZC1vZmYtYnk6IENvbmcgV2FuZyA8eGl5b3Uu
d2FuZ2NvbmdAZ21haWwuY29tPgpbVHJvbmQ6IHJlcGxhY2UgdXNlcyBvZiByZW1vdmVfcHJvY19l
bnRyeSgpIHdpdGggcmVtb3ZlX3Byb2Nfc3VidHJlZSgpCmFzIHN1Z2dlc3RlZCBieSBBbCBWaXJv
XQpDYzogc3RhYmxlQHZnZXIua2VybmVsLm9yZyAjIDMuNC54IDogNjViMzg4NTFhMTc6IE5GUzog
Rml4IC9wcm9jL2ZzL25mc2ZzL3NlcnZlcnMKQ2M6IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcgIyAz
LjQueApTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmlt
YXJ5ZGF0YS5jb20+Ci0tLQogZnMvbmZzL2NsaWVudC5jIHwgMTIgKysrLS0tLS0tLS0tCiAxIGZp
bGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCspLCA5IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBh
L2ZzL25mcy9jbGllbnQuYyBiL2ZzL25mcy9jbGllbnQuYwppbmRleCAxYzVmZjZkNTgzODUuLjZh
NGYzNjY2ZTI3MyAxMDA2NDQKLS0tIGEvZnMvbmZzL2NsaWVudC5jCisrKyBiL2ZzL25mcy9jbGll
bnQuYwpAQCAtMTQxMiwyNCArMTQxMiwxOCBAQCBpbnQgbmZzX2ZzX3Byb2NfbmV0X2luaXQoc3Ry
dWN0IG5ldCAqbmV0KQogCXAgPSBwcm9jX2NyZWF0ZSgidm9sdW1lcyIsIFNfSUZSRUd8U19JUlVH
TywKIAkJCW5uLT5wcm9jX25mc2ZzLCAmbmZzX3ZvbHVtZV9saXN0X2ZvcHMpOwogCWlmICghcCkK
LQkJZ290byBlcnJvcl8yOworCQlnb3RvIGVycm9yXzE7CiAJcmV0dXJuIDA7CiAKLWVycm9yXzI6
Ci0JcmVtb3ZlX3Byb2NfZW50cnkoInNlcnZlcnMiLCBubi0+cHJvY19uZnNmcyk7CiBlcnJvcl8x
OgotCXJlbW92ZV9wcm9jX2VudHJ5KCJmcy9uZnNmcyIsIE5VTEwpOworCXJlbW92ZV9wcm9jX3N1
YnRyZWUoIm5mc2ZzIiwgbmV0LT5wcm9jX25ldCk7CiBlcnJvcl8wOgogCXJldHVybiAtRU5PTUVN
OwogfQogCiB2b2lkIG5mc19mc19wcm9jX25ldF9leGl0KHN0cnVjdCBuZXQgKm5ldCkKIHsKLQlz
dHJ1Y3QgbmZzX25ldCAqbm4gPSBuZXRfZ2VuZXJpYyhuZXQsIG5mc19uZXRfaWQpOwotCi0JcmVt
b3ZlX3Byb2NfZW50cnkoInZvbHVtZXMiLCBubi0+cHJvY19uZnNmcyk7Ci0JcmVtb3ZlX3Byb2Nf
ZW50cnkoInNlcnZlcnMiLCBubi0+cHJvY19uZnNmcyk7Ci0JcmVtb3ZlX3Byb2NfZW50cnkoImZz
L25mc2ZzIiwgTlVMTCk7CisJcmVtb3ZlX3Byb2Nfc3VidHJlZSgibmZzZnMiLCBuZXQtPnByb2Nf
bmV0KTsKIH0KIAogLyoKLS0gCjEuOS4zCgo=
--089e0122a71ed81a550502968b44--

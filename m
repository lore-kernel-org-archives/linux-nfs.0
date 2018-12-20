Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A54CC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 09:33:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 58FFF20449
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 09:33:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732943AbeLTJac (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 04:30:32 -0500
Received: from relay.sw.ru ([185.231.240.75]:35634 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732935AbeLTJac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 04:30:32 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gZuep-0003Mk-7Z; Thu, 20 Dec 2018 12:30:19 +0300
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
 <20181217215026.GA8564@fieldses.org>
 <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
 <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
 <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
 <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
 <eef084b9-4f1e-99e7-4d1a-a6e88b61d564@virtuozzo.com>
 <48844583b23fbbac600dfc86c49a7c71c5db36eb.camel@hammerspace.com>
 <d0b35e30-2eae-123e-19c6-fcd3cd93ab86@virtuozzo.com>
 <2459cc18-3c14-fb68-def6-eb09fc096613@virtuozzo.com>
 <76d71f3412b3104b917aa836eede3447db35bda0.camel@hammerspace.com>
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <11b7dec4-cd81-cb23-68f9-d56b5df79337@virtuozzo.com>
Date:   Thu, 20 Dec 2018 12:30:18 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <76d71f3412b3104b917aa836eede3447db35bda0.camel@hammerspace.com>
Content-Type: multipart/mixed;
 boundary="------------D8FFCEC06629EB9473563817"
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a multi-part message in MIME format.
--------------D8FFCEC06629EB9473563817
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 12/20/18 4:58 AM, Trond Myklebust wrote:
> On Thu, 2018-12-20 at 04:39 +0300, Vasily Averin wrote:
>> Dear Trond,
>> Red Hat security believes the problem is quite important security
>> issue:
>> https://access.redhat.com/security/cve/cve-2018-16884
>>
>> Fix should be backported to affected distributions.
>>
>> Could you please approve my first patch and push it to stable@ ?
>> From my PoV it is correctly fixes the problem, it breaks nothing and
>> easy for backports,
>> lightly modified it can be even live-patched.
>>
>> Other patches including switch to using empty rqst->rq_xprt can wait.
>>
> 
> That patch is not acceptable for upstream.

In this case how about my initial plan B -- make svc_serv per net-namespace?
It executes additional per-netns nfsv4 callback threads 
but does not require any changes in existing sunrpc code?

--------------D8FFCEC06629EB9473563817
Content-Type: text/plain; charset=UTF-8;
 name="diff-ms-nfs-make-svc_serv-per-netns"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="diff-ms-nfs-make-svc_serv-per-netns"

ZGlmZiAtLWdpdCBhL2ZzL25mcy9jYWxsYmFjay5jIGIvZnMvbmZzL2NhbGxiYWNrLmMKaW5k
ZXggNTA5ZGM1YWRlYjhmLi5kZjY5MzlkYTlkNzMgMTAwNjQ0Ci0tLSBhL2ZzL25mcy9jYWxs
YmFjay5jCisrKyBiL2ZzL25mcy9jYWxsYmFjay5jCkBAIC0zMCwxMiArMzAsNiBAQAogCiAj
ZGVmaW5lIE5GU0RCR19GQUNJTElUWSBORlNEQkdfQ0FMTEJBQ0sKIAotc3RydWN0IG5mc19j
YWxsYmFja19kYXRhIHsKLQl1bnNpZ25lZCBpbnQgdXNlcnM7Ci0Jc3RydWN0IHN2Y19zZXJ2
ICpzZXJ2OwotfTsKLQotc3RhdGljIHN0cnVjdCBuZnNfY2FsbGJhY2tfZGF0YSBuZnNfY2Fs
bGJhY2tfaW5mb1tORlM0X01BWF9NSU5PUl9WRVJTSU9OICsgMV07CiBzdGF0aWMgREVGSU5F
X01VVEVYKG5mc19jYWxsYmFja19tdXRleCk7CiBzdGF0aWMgc3RydWN0IHN2Y19wcm9ncmFt
IG5mczRfY2FsbGJhY2tfcHJvZ3JhbTsKIApAQCAtMjUyLDIyICsyNDYsMjMgQEAgc3RhdGlj
IGNvbnN0IHN0cnVjdCBzdmNfc2Vydl9vcHMgKm5mczRfY2Jfc3Zfb3BzW10gPSB7CiB9Owog
I2VuZGlmCiAKLXN0YXRpYyBzdHJ1Y3Qgc3ZjX3NlcnYgKm5mc19jYWxsYmFja19jcmVhdGVf
c3ZjKGludCBtaW5vcnZlcnNpb24pCitzdGF0aWMgc3RydWN0IHN2Y19zZXJ2ICpuZnNfY2Fs
bGJhY2tfY3JlYXRlX3N2YyhpbnQgbWlub3J2ZXJzaW9uLAorCQkJCQkJc3RydWN0IG5ldCAq
bmV0KQogewotCXN0cnVjdCBuZnNfY2FsbGJhY2tfZGF0YSAqY2JfaW5mbyA9ICZuZnNfY2Fs
bGJhY2tfaW5mb1ttaW5vcnZlcnNpb25dOworCXN0cnVjdCBuZnNfbmV0ICpubiA9IG5ldF9n
ZW5lcmljKG5ldCwgbmZzX25ldF9pZCk7CiAJY29uc3Qgc3RydWN0IHN2Y19zZXJ2X29wcyAq
c3Zfb3BzOwotCXN0cnVjdCBzdmNfc2VydiAqc2VydjsKKwlzdHJ1Y3Qgc3ZjX3NlcnYgKnNl
cnYgPSBubi0+c2VydlttaW5vcnZlcnNpb25dOwogCiAJLyoKIAkgKiBDaGVjayB3aGV0aGVy
IHdlJ3JlIGFscmVhZHkgdXAgYW5kIHJ1bm5pbmcuCiAJICovCi0JaWYgKGNiX2luZm8tPnNl
cnYpIHsKKwlpZiAoc2VydikgewogCQkvKgogCQkgKiBOb3RlOiBpbmNyZWFzZSBzZXJ2aWNl
IHVzYWdlLCBiZWNhdXNlIGxhdGVyIGluIGNhc2Ugb2YgZXJyb3IKIAkJICogc3ZjX2Rlc3Ry
b3koKSB3aWxsIGJlIGNhbGxlZC4KIAkJICovCi0JCXN2Y19nZXQoY2JfaW5mby0+c2Vydik7
Ci0JCXJldHVybiBjYl9pbmZvLT5zZXJ2OworCQlzdmNfZ2V0KHNlcnYpOworCQlyZXR1cm4g
c2VydjsKIAl9CiAKIAlzd2l0Y2ggKG1pbm9ydmVyc2lvbikgewpAQCAtMjgxLDIwICsyNzYs
MTIgQEAgc3RhdGljIHN0cnVjdCBzdmNfc2VydiAqbmZzX2NhbGxiYWNrX2NyZWF0ZV9zdmMo
aW50IG1pbm9ydmVyc2lvbikKIAlpZiAoc3Zfb3BzID09IE5VTEwpCiAJCXJldHVybiBFUlJf
UFRSKC1FTk9UU1VQUCk7CiAKLQkvKgotCSAqIFNhbml0eSBjaGVjazogaWYgdGhlcmUncyBu
byB0YXNrLAotCSAqIHdlIHNob3VsZCBiZSB0aGUgZmlyc3QgdXNlciAuLi4KLQkgKi8KLQlp
ZiAoY2JfaW5mby0+dXNlcnMpCi0JCXByaW50ayhLRVJOX1dBUk5JTkcgIm5mc19jYWxsYmFj
a19jcmVhdGVfc3ZjOiBubyBrdGhyZWFkLCAlZCB1c2Vycz8/XG4iLAotCQkJY2JfaW5mby0+
dXNlcnMpOwotCiAJc2VydiA9IHN2Y19jcmVhdGVfcG9vbGVkKCZuZnM0X2NhbGxiYWNrX3By
b2dyYW0sIE5GUzRfQ0FMTEJBQ0tfQlVGU0laRSwgc3Zfb3BzKTsKIAlpZiAoIXNlcnYpIHsK
IAkJcHJpbnRrKEtFUk5fRVJSICJuZnNfY2FsbGJhY2tfY3JlYXRlX3N2YzogY3JlYXRlIHNl
cnZpY2UgZmFpbGVkXG4iKTsKIAkJcmV0dXJuIEVSUl9QVFIoLUVOT01FTSk7CiAJfQotCWNi
X2luZm8tPnNlcnYgPSBzZXJ2OworCW5uLT5zZXJ2W21pbm9ydmVyc2lvbl0gPSBzZXJ2Owog
CS8qIEFzIHRoZXJlIGlzIG9ubHkgb25lIHRocmVhZCB3ZSBuZWVkIHRvIG92ZXItcmlkZSB0
aGUKIAkgKiBkZWZhdWx0IG1heGltdW0gb2YgODAgY29ubmVjdGlvbnMKIAkgKi8KQEAgLTMw
OCwxNCArMjk1LDE0IEBAIHN0YXRpYyBzdHJ1Y3Qgc3ZjX3NlcnYgKm5mc19jYWxsYmFja19j
cmVhdGVfc3ZjKGludCBtaW5vcnZlcnNpb24pCiAgKi8KIGludCBuZnNfY2FsbGJhY2tfdXAo
dTMyIG1pbm9ydmVyc2lvbiwgc3RydWN0IHJwY194cHJ0ICp4cHJ0KQogewotCXN0cnVjdCBz
dmNfc2VydiAqc2VydjsKLQlzdHJ1Y3QgbmZzX2NhbGxiYWNrX2RhdGEgKmNiX2luZm8gPSAm
bmZzX2NhbGxiYWNrX2luZm9bbWlub3J2ZXJzaW9uXTsKLQlpbnQgcmV0OwogCXN0cnVjdCBu
ZXQgKm5ldCA9IHhwcnQtPnhwcnRfbmV0OworCXN0cnVjdCBuZnNfbmV0ICpubiA9IG5ldF9n
ZW5lcmljKG5ldCwgbmZzX25ldF9pZCk7CisJc3RydWN0IHN2Y19zZXJ2ICpzZXJ2ID0gbm4t
PnNlcnZbbWlub3J2ZXJzaW9uXTsKKwlpbnQgcmV0OwogCiAJbXV0ZXhfbG9jaygmbmZzX2Nh
bGxiYWNrX211dGV4KTsKIAotCXNlcnYgPSBuZnNfY2FsbGJhY2tfY3JlYXRlX3N2YyhtaW5v
cnZlcnNpb24pOworCXNlcnYgPSBuZnNfY2FsbGJhY2tfY3JlYXRlX3N2YyhtaW5vcnZlcnNp
b24sIG5ldCk7CiAJaWYgKElTX0VSUihzZXJ2KSkgewogCQlyZXQgPSBQVFJfRVJSKHNlcnYp
OwogCQlnb3RvIGVycl9jcmVhdGU7CkBAIC0zMjksNyArMzE2LDYgQEAgaW50IG5mc19jYWxs
YmFja191cCh1MzIgbWlub3J2ZXJzaW9uLCBzdHJ1Y3QgcnBjX3hwcnQgKnhwcnQpCiAJaWYg
KHJldCA8IDApCiAJCWdvdG8gZXJyX3N0YXJ0OwogCi0JY2JfaW5mby0+dXNlcnMrKzsKIAkv
KgogCSAqIHN2Y19jcmVhdGUgY3JlYXRlcyB0aGUgc3ZjX3NlcnYgd2l0aCBzdl9ucnRocmVh
ZHMgPT0gMSwgYW5kIHRoZW4KIAkgKiBzdmNfcHJlcGFyZV90aHJlYWQgaW5jcmVtZW50cyB0
aGF0LiBTbyB3ZSBuZWVkIHRvIGNhbGwgc3ZjX2Rlc3Ryb3kKQEAgLTMzNyw4ICszMjMsOCBA
QCBpbnQgbmZzX2NhbGxiYWNrX3VwKHUzMiBtaW5vcnZlcnNpb24sIHN0cnVjdCBycGNfeHBy
dCAqeHBydCkKIAkgKiB0aHJlYWQgZXhpdHMuCiAJICovCiBlcnJfbmV0OgotCWlmICghY2Jf
aW5mby0+dXNlcnMpCi0JCWNiX2luZm8tPnNlcnYgPSBOVUxMOworCWlmICghbm4tPmNiX3Vz
ZXJzW21pbm9ydmVyc2lvbl0pCisJCW5uLT5zZXJ2W21pbm9ydmVyc2lvbl0gPSBOVUxMOwog
CXN2Y19kZXN0cm95KHNlcnYpOwogZXJyX2NyZWF0ZToKIAltdXRleF91bmxvY2soJm5mc19j
YWxsYmFja19tdXRleCk7CkBAIC0zNTUsMTkgKzM0MSwxOCBAQCBpbnQgbmZzX2NhbGxiYWNr
X3VwKHUzMiBtaW5vcnZlcnNpb24sIHN0cnVjdCBycGNfeHBydCAqeHBydCkKICAqLwogdm9p
ZCBuZnNfY2FsbGJhY2tfZG93bihpbnQgbWlub3J2ZXJzaW9uLCBzdHJ1Y3QgbmV0ICpuZXQp
CiB7Ci0Jc3RydWN0IG5mc19jYWxsYmFja19kYXRhICpjYl9pbmZvID0gJm5mc19jYWxsYmFj
a19pbmZvW21pbm9ydmVyc2lvbl07CisJc3RydWN0IG5mc19uZXQgKm5uID0gbmV0X2dlbmVy
aWMobmV0LCBuZnNfbmV0X2lkKTsKIAlzdHJ1Y3Qgc3ZjX3NlcnYgKnNlcnY7CiAKIAltdXRl
eF9sb2NrKCZuZnNfY2FsbGJhY2tfbXV0ZXgpOwotCXNlcnYgPSBjYl9pbmZvLT5zZXJ2Owor
CXNlcnYgPSBubi0+c2VydlttaW5vcnZlcnNpb25dOwogCW5mc19jYWxsYmFja19kb3duX25l
dChtaW5vcnZlcnNpb24sIHNlcnYsIG5ldCk7Ci0JY2JfaW5mby0+dXNlcnMtLTsKLQlpZiAo
Y2JfaW5mby0+dXNlcnMgPT0gMCkgeworCWlmIChubi0+Y2JfdXNlcnNbbWlub3J2ZXJzaW9u
XSA9PSAwKSB7CiAJCXN2Y19nZXQoc2Vydik7CiAJCXNlcnYtPnN2X29wcy0+c3ZvX3NldHVw
KHNlcnYsIE5VTEwsIDApOwogCQlzdmNfZGVzdHJveShzZXJ2KTsKIAkJZHByaW50aygibmZz
X2NhbGxiYWNrX2Rvd246IHNlcnZpY2UgZGVzdHJveWVkXG4iKTsKLQkJY2JfaW5mby0+c2Vy
diA9IE5VTEw7CisJCW5uLT5zZXJ2W21pbm9ydmVyc2lvbl0gPSBOVUxMOwogCX0KIAltdXRl
eF91bmxvY2soJm5mc19jYWxsYmFja19tdXRleCk7CiB9CmRpZmYgLS1naXQgYS9mcy9uZnMv
bmV0bnMuaCBiL2ZzL25mcy9uZXRucy5oCmluZGV4IGZjOTk3OGM1ODI2NS4uYTQ5OTc4ZDJm
YjBkIDEwMDY0NAotLS0gYS9mcy9uZnMvbmV0bnMuaAorKysgYi9mcy9uZnMvbmV0bnMuaApA
QCAtMjksNiArMjksNyBAQCBzdHJ1Y3QgbmZzX25ldCB7CiAJdW5zaWduZWQgc2hvcnQgbmZz
X2NhbGxiYWNrX3RjcHBvcnQ2OwogCWludCBjYl91c2Vyc1tORlM0X01BWF9NSU5PUl9WRVJT
SU9OICsgMV07CiAjZW5kaWYKKwlzdHJ1Y3Qgc3ZjX3NlcnYgKnNlcnZbTkZTNF9NQVhfTUlO
T1JfVkVSU0lPTiArIDFdOwogCXNwaW5sb2NrX3QgbmZzX2NsaWVudF9sb2NrOwogCWt0aW1l
X3QgYm9vdF90aW1lOwogI2lmZGVmIENPTkZJR19QUk9DX0ZTCg==
--------------D8FFCEC06629EB9473563817--

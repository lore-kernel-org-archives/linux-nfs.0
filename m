Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B942C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 11:25:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EADE22184A
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 11:25:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729269AbeLSLZS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 06:25:18 -0500
Received: from relay.sw.ru ([185.231.240.75]:50994 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729255AbeLSLZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 06:25:17 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gZZyH-00067R-PO; Wed, 19 Dec 2018 14:25:01 +0300
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
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <d0b35e30-2eae-123e-19c6-fcd3cd93ab86@virtuozzo.com>
Date:   Wed, 19 Dec 2018 14:25:00 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <48844583b23fbbac600dfc86c49a7c71c5db36eb.camel@hammerspace.com>
Content-Type: multipart/mixed;
 boundary="------------2E3FA2AC8374D272B593860A"
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a multi-part message in MIME format.
--------------2E3FA2AC8374D272B593860A
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit



On 12/18/18 11:43 PM, Trond Myklebust wrote:
> On Tue, 2018-12-18 at 23:02 +0300, Vasily Averin wrote:
>> On 12/18/18 5:55 PM, Trond Myklebust wrote:
>>>>> It probably also requires us to store a pointer to struct net
>>>>> in
>>>>> the
>>>>> struct svc_rqst so that nfs4_callback_compound() and
>>>>> svcauth_gss_accept() can find it, but that should be OK since
>>>>> the
>>>>> transport already has that referenced.
>>
>> Ok, I can fix these functions and their sub-calls.
>> However  rqst->rq_xprt is used in other functions that seems can be
>> called inside svc_process_common() 
>> - in trace_svc_process(rqstp, progp->pg_name);
>> - in svc_reserve_auth(rqstp, ...) -> svc_reserve()
>> - svc_authorise() -> svcauth_gss_release()
>>
>> It seems I should fix these places too, it isn't?
>> could you please advise how to fix svc_reserve() ?
> 
> We don't want svc_reserve() to run at all for the back channel, so I
> guess that a test for rqstp->rq_xprt != NULL is appropriate there too.
> 
> svcauth_gss_release() is just using rqstp->rq_xprt to find the net
> namespace, so if you add a pointer rqstp->rq_net to fix
> nfs4_callback_compound, then that will fix the gss case as well.
> 
> For trace_svc_process(), maybe pull rqst->rq_xprt->xpt_remotebuf out of
> the tracepoint definition in include/trace/events/sunrpc.h and make it
> a tracepoint argument that is allowed to be NULL?

This one seems works, could you please check it before formal submit ?
  NFSv4 callback-1644  [002] ....  4731.064372: svc_process: addr=(null) xid=0x0b0924e3 service=NFSv4 callback vers=1 proc=1

Frankly speaking I'm afraid that I missed something,
rqstp->rq_xprt is widely used and nobody expect that it can be NULL.

And even I missed nothing --  it's quite tricky anyway.
Future cahnges can add new calls or execute old non-empty-xprt-aware
functions and trigger crash in some exotic configuration.

Thank you,
	Vasily Averin

--------------2E3FA2AC8374D272B593860A
Content-Type: text/plain; charset=UTF-8;
 name="diff-empty-rq_xprt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="diff-empty-rq_xprt"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvc3VucnBjL3N2Yy5oIGIvaW5jbHVkZS9saW51
eC9zdW5ycGMvc3ZjLmgKaW5kZXggNzNlMTMwYTg0MGNlLi5mODdkMmJhODg4NjkgMTAwNjQ0
Ci0tLSBhL2luY2x1ZGUvbGludXgvc3VucnBjL3N2Yy5oCisrKyBiL2luY2x1ZGUvbGludXgv
c3VucnBjL3N2Yy5oCkBAIC0yOTUsOSArMjk1LDEyIEBAIHN0cnVjdCBzdmNfcnFzdCB7CiAJ
c3RydWN0IHN2Y19jYWNoZXJlcCAqCXJxX2NhY2hlcmVwOwkvKiBjYWNoZSBpbmZvICovCiAJ
c3RydWN0IHRhc2tfc3RydWN0CSpycV90YXNrOwkvKiBzZXJ2aWNlIHRocmVhZCAqLwogCXNw
aW5sb2NrX3QJCXJxX2xvY2s7CS8qIHBlci1yZXF1ZXN0IGxvY2sgKi8KKwlzdHJ1Y3QgbmV0
ICoJCXJxX2JjX25ldDsJLyogcG9pbnRlciB0byBiYWNrY2hhbm5lbCdzCisJCQkJCQkgKiBu
ZXQgbmFtZXNwYWNlCisJCQkJCQkgKi8KIH07CiAKLSNkZWZpbmUgU1ZDX05FVChzdmNfcnFz
dCkJKHN2Y19ycXN0LT5ycV94cHJ0LT54cHRfbmV0KQorI2RlZmluZSBTVkNfTkVUKHJxc3Qp
IChycXN0LT5ycV94cHJ0ID8gcnFzdC0+cnFfeHBydC0+eHB0X25ldCA6IHJxc3QtPnJxX2Jj
X25ldCkKIAogLyoKICAqIFJpZ29yb3VzIHR5cGUgY2hlY2tpbmcgb24gc29ja2FkZHIgdHlw
ZSBjb252ZXJzaW9ucwpkaWZmIC0tZ2l0IGEvaW5jbHVkZS90cmFjZS9ldmVudHMvc3VucnBj
LmggYi9pbmNsdWRlL3RyYWNlL2V2ZW50cy9zdW5ycGMuaAppbmRleCAyOGUzODQxODZjMzUu
LmRmNDMwNWJlNzNkNiAxMDA2NDQKLS0tIGEvaW5jbHVkZS90cmFjZS9ldmVudHMvc3VucnBj
LmgKKysrIGIvaW5jbHVkZS90cmFjZS9ldmVudHMvc3VucnBjLmgKQEAgLTU2OSw3ICs1Njks
NyBAQCBUUkFDRV9FVkVOVChzdmNfcHJvY2VzcywKIAkJX19maWVsZCh1MzIsIHZlcnMpCiAJ
CV9fZmllbGQodTMyLCBwcm9jKQogCQlfX3N0cmluZyhzZXJ2aWNlLCBuYW1lKQotCQlfX3N0
cmluZyhhZGRyLCBycXN0LT5ycV94cHJ0LT54cHRfcmVtb3RlYnVmKQorCQlfX3N0cmluZyhh
ZGRyLCBycXN0LT5ycV94cHJ0ID8gcnFzdC0+cnFfeHBydC0+eHB0X3JlbW90ZWJ1ZiA6ICIo
bnVsbCkiKQogCSksCiAKIAlUUF9mYXN0X2Fzc2lnbigKQEAgLTU3Nyw3ICs1NzcsNyBAQCBU
UkFDRV9FVkVOVChzdmNfcHJvY2VzcywKIAkJX19lbnRyeS0+dmVycyA9IHJxc3QtPnJxX3Zl
cnM7CiAJCV9fZW50cnktPnByb2MgPSBycXN0LT5ycV9wcm9jOwogCQlfX2Fzc2lnbl9zdHIo
c2VydmljZSwgbmFtZSk7Ci0JCV9fYXNzaWduX3N0cihhZGRyLCBycXN0LT5ycV94cHJ0LT54
cHRfcmVtb3RlYnVmKTsKKwkJX19hc3NpZ25fc3RyKGFkZHIsIHJxc3QtPnJxX3hwcnQgPyBy
cXN0LT5ycV94cHJ0LT54cHRfcmVtb3RlYnVmIDogIihudWxsKSIpOwogCSksCiAKIAlUUF9w
cmludGsoImFkZHI9JXMgeGlkPTB4JTA4eCBzZXJ2aWNlPSVzIHZlcnM9JXUgcHJvYz0ldSIs
CmRpZmYgLS1naXQgYS9uZXQvc3VucnBjL2F1dGhfZ3NzL3N2Y2F1dGhfZ3NzLmMgYi9uZXQv
c3VucnBjL2F1dGhfZ3NzL3N2Y2F1dGhfZ3NzLmMKaW5kZXggMWVjZTRiYzNlYjhkLi4xNTI3
OTBlZDMwOWMgMTAwNjQ0Ci0tLSBhL25ldC9zdW5ycGMvYXV0aF9nc3Mvc3ZjYXV0aF9nc3Mu
YworKysgYi9uZXQvc3VucnBjL2F1dGhfZ3NzL3N2Y2F1dGhfZ3NzLmMKQEAgLTExNDIsNyAr
MTE0Miw3IEBAIHN0YXRpYyBpbnQgc3ZjYXV0aF9nc3NfbGVnYWN5X2luaXQoc3RydWN0IHN2
Y19ycXN0ICpycXN0cCwKIAlzdHJ1Y3Qga3ZlYyAqcmVzdiA9ICZycXN0cC0+cnFfcmVzLmhl
YWRbMF07CiAJc3RydWN0IHJzaSAqcnNpcCwgcnNpa2V5OwogCWludCByZXQ7Ci0Jc3RydWN0
IHN1bnJwY19uZXQgKnNuID0gbmV0X2dlbmVyaWMocnFzdHAtPnJxX3hwcnQtPnhwdF9uZXQs
IHN1bnJwY19uZXRfaWQpOworCXN0cnVjdCBzdW5ycGNfbmV0ICpzbiA9IG5ldF9nZW5lcmlj
KFNWQ19ORVQocnFzdHApLCBzdW5ycGNfbmV0X2lkKTsKIAogCW1lbXNldCgmcnNpa2V5LCAw
LCBzaXplb2YocnNpa2V5KSk7CiAJcmV0ID0gZ3NzX3JlYWRfdmVyZihnYywgYXJndiwgYXV0
aHAsCkBAIC0xMjUzLDcgKzEyNTMsNyBAQCBzdGF0aWMgaW50IHN2Y2F1dGhfZ3NzX3Byb3h5
X2luaXQoc3RydWN0IHN2Y19ycXN0ICpycXN0cCwKIAl1aW50NjRfdCBoYW5kbGU7CiAJaW50
IHN0YXR1czsKIAlpbnQgcmV0OwotCXN0cnVjdCBuZXQgKm5ldCA9IHJxc3RwLT5ycV94cHJ0
LT54cHRfbmV0OworCXN0cnVjdCBuZXQgKm5ldCA9IFNWQ19ORVQocnFzdHApOwogCXN0cnVj
dCBzdW5ycGNfbmV0ICpzbiA9IG5ldF9nZW5lcmljKG5ldCwgc3VucnBjX25ldF9pZCk7CiAK
IAltZW1zZXQoJnVkLCAwLCBzaXplb2YodWQpKTsKQEAgLTE0NDQsNyArMTQ0NCw3IEBAIHN2
Y2F1dGhfZ3NzX2FjY2VwdChzdHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3RwLCBfX2JlMzIgKmF1dGhw
KQogCV9fYmUzMgkJKnJwY3N0YXJ0OwogCV9fYmUzMgkJKnJlamVjdF9zdGF0ID0gcmVzdi0+
aW92X2Jhc2UgKyByZXN2LT5pb3ZfbGVuOwogCWludAkJcmV0OwotCXN0cnVjdCBzdW5ycGNf
bmV0ICpzbiA9IG5ldF9nZW5lcmljKHJxc3RwLT5ycV94cHJ0LT54cHRfbmV0LCBzdW5ycGNf
bmV0X2lkKTsKKwlzdHJ1Y3Qgc3VucnBjX25ldCAqc24gPSBuZXRfZ2VuZXJpYyhTVkNfTkVU
KHJxc3RwKSwgc3VucnBjX25ldF9pZCk7CiAKIAlkcHJpbnRrKCJSUEM6ICAgICAgIHN2Y2F1
dGhfZ3NzOiBhcmd2LT5pb3ZfbGVuID0gJXpkXG4iLAogCQkJYXJndi0+aW92X2xlbik7CkBA
IC0xNzM0LDcgKzE3MzQsNyBAQCBzdmNhdXRoX2dzc19yZWxlYXNlKHN0cnVjdCBzdmNfcnFz
dCAqcnFzdHApCiAJc3RydWN0IHJwY19nc3Nfd2lyZV9jcmVkICpnYyA9ICZnc2QtPmNsY3Jl
ZDsKIAlzdHJ1Y3QgeGRyX2J1ZiAqcmVzYnVmID0gJnJxc3RwLT5ycV9yZXM7CiAJaW50IHN0
YXQgPSAtRUlOVkFMOwotCXN0cnVjdCBzdW5ycGNfbmV0ICpzbiA9IG5ldF9nZW5lcmljKHJx
c3RwLT5ycV94cHJ0LT54cHRfbmV0LCBzdW5ycGNfbmV0X2lkKTsKKwlzdHJ1Y3Qgc3VucnBj
X25ldCAqc24gPSBuZXRfZ2VuZXJpYyhTVkNfTkVUKHJxc3RwKSwgc3VucnBjX25ldF9pZCk7
CiAKIAlpZiAoZ2MtPmdjX3Byb2MgIT0gUlBDX0dTU19QUk9DX0RBVEEpCiAJCWdvdG8gb3V0
OwpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9zdmMuYyBiL25ldC9zdW5ycGMvc3ZjLmMKaW5k
ZXggYTcyNjRmZDFiM2RiLi42ZWJiMDMyNDc0OGYgMTAwNjQ0Ci0tLSBhL25ldC9zdW5ycGMv
c3ZjLmMKKysrIGIvbmV0L3N1bnJwYy9zdmMuYwpAQCAtMTE0OCw3ICsxMTQ4LDggQEAgc3Rh
dGljIF9fcHJpbnRmKDIsMykgdm9pZCBzdmNfcHJpbnRrKHN0cnVjdCBzdmNfcnFzdCAqcnFz
dHAsIGNvbnN0IGNoYXIgKmZtdCwgLi4KICAqIENvbW1vbiByb3V0aW5lIGZvciBwcm9jZXNz
aW5nIHRoZSBSUEMgcmVxdWVzdC4KICAqLwogc3RhdGljIGludAotc3ZjX3Byb2Nlc3NfY29t
bW9uKHN0cnVjdCBzdmNfcnFzdCAqcnFzdHAsIHN0cnVjdCBrdmVjICphcmd2LCBzdHJ1Y3Qg
a3ZlYyAqcmVzdikKK3N2Y19wcm9jZXNzX2NvbW1vbihzdHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3Rw
LCBzdHJ1Y3Qga3ZlYyAqYXJndiwgCisJCSAgIHN0cnVjdCBrdmVjICpyZXN2LCBjb25zdCBz
dHJ1Y3Qgc3ZjX3hwcnRfb3BzICp4b3BzKQogewogCXN0cnVjdCBzdmNfcHJvZ3JhbQkqcHJv
Z3A7CiAJY29uc3Qgc3RydWN0IHN2Y192ZXJzaW9uICp2ZXJzcCA9IE5VTEw7CS8qIGNvbXBp
bGVyIGZvb2QgKi8KQEAgLTExNzIsNyArMTE3Myw3IEBAIHN2Y19wcm9jZXNzX2NvbW1vbihz
dHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3RwLCBzdHJ1Y3Qga3ZlYyAqYXJndiwgc3RydWN0IGt2ZWMg
KnJlc3YpCiAJY2xlYXJfYml0KFJRX0RST1BNRSwgJnJxc3RwLT5ycV9mbGFncyk7CiAKIAkv
KiBTZXR1cCByZXBseSBoZWFkZXIgKi8KLQlycXN0cC0+cnFfeHBydC0+eHB0X29wcy0+eHBv
X3ByZXBfcmVwbHlfaGRyKHJxc3RwKTsKKwl4b3BzLT54cG9fcHJlcF9yZXBseV9oZHIocnFz
dHApOwogCiAJc3ZjX3B1dHUzMihyZXN2LCBycXN0cC0+cnFfeGlkKTsKIApAQCAtMTI0NCw3
ICsxMjQ1LDcgQEAgc3ZjX3Byb2Nlc3NfY29tbW9uKHN0cnVjdCBzdmNfcnFzdCAqcnFzdHAs
IHN0cnVjdCBrdmVjICphcmd2LCBzdHJ1Y3Qga3ZlYyAqcmVzdikKIAkgKiBmb3IgbG93ZXIg
dmVyc2lvbnMuIFJQQ19QUk9HX01JU01BVENIIHNlZW1zIHRvIGJlIHRoZSBjbG9zZXN0CiAJ
ICogZml0LgogCSAqLwotCWlmICh2ZXJzcC0+dnNfbmVlZF9jb25nX2N0cmwgJiYKKwlpZiAo
dmVyc3AtPnZzX25lZWRfY29uZ19jdHJsICYmIHJxc3RwLT5ycV94cHJ0ICYmCiAJICAgICF0
ZXN0X2JpdChYUFRfQ09OR19DVFJMLCAmcnFzdHAtPnJxX3hwcnQtPnhwdF9mbGFncykpCiAJ
CWdvdG8gZXJyX2JhZF92ZXJzOwogCkBAIC0xMzM2LDcgKzEzMzcsNyBAQCBzdmNfcHJvY2Vz
c19jb21tb24oc3RydWN0IHN2Y19ycXN0ICpycXN0cCwgc3RydWN0IGt2ZWMgKmFyZ3YsIHN0
cnVjdCBrdmVjICpyZXN2KQogCXJldHVybiAwOwogCiAgY2xvc2U6Ci0JaWYgKHRlc3RfYml0
KFhQVF9URU1QLCAmcnFzdHAtPnJxX3hwcnQtPnhwdF9mbGFncykpCisJaWYgKHJxc3RwLT5y
cV94cHJ0ICYmIHRlc3RfYml0KFhQVF9URU1QLCAmcnFzdHAtPnJxX3hwcnQtPnhwdF9mbGFn
cykpCiAJCXN2Y19jbG9zZV94cHJ0KHJxc3RwLT5ycV94cHJ0KTsKIAlkcHJpbnRrKCJzdmM6
IHN2Y19wcm9jZXNzIGNsb3NlXG4iKTsKIAlyZXR1cm4gMDsKQEAgLTE0MzIsNyArMTQzMyw4
IEBAIHN2Y19wcm9jZXNzKHN0cnVjdCBzdmNfcnFzdCAqcnFzdHApCiAJfQogCiAJLyogUmV0
dXJucyAxIGZvciBzZW5kLCAwIGZvciBkcm9wICovCi0JaWYgKGxpa2VseShzdmNfcHJvY2Vz
c19jb21tb24ocnFzdHAsIGFyZ3YsIHJlc3YpKSkKKwlpZiAobGlrZWx5KHN2Y19wcm9jZXNz
X2NvbW1vbihycXN0cCwgYXJndiwgcmVzdiwKKwkJCQkJcnFzdHAtPnJxX3hwcnQtPnhwdF9v
cHMpKSkKIAkJcmV0dXJuIHN2Y19zZW5kKHJxc3RwKTsKIAogb3V0X2Ryb3A6CkBAIC0xNDY1
LDEwICsxNDY3LDEwIEBAIGJjX3N2Y19wcm9jZXNzKHN0cnVjdCBzdmNfc2VydiAqc2Vydiwg
c3RydWN0IHJwY19ycXN0ICpyZXEsCiAJCWdvdG8gcHJvY19lcnJvcjsKIAogCS8qIEJ1aWxk
IHRoZSBzdmNfcnFzdCB1c2VkIGJ5IHRoZSBjb21tb24gcHJvY2Vzc2luZyByb3V0aW5lICov
Ci0JcnFzdHAtPnJxX3hwcnQgPSBzX3hwcnQ7CiAJcnFzdHAtPnJxX3hpZCA9IHJlcS0+cnFf
eGlkOwogCXJxc3RwLT5ycV9wcm90ID0gcmVxLT5ycV94cHJ0LT5wcm90OwogCXJxc3RwLT5y
cV9zZXJ2ZXIgPSBzZXJ2OworCXJxc3RwLT5ycV9iY19uZXQgPSBuZXQ7CiAKIAlycXN0cC0+
cnFfYWRkcmxlbiA9IHNpemVvZihyZXEtPnJxX3hwcnQtPmFkZHIpOwogCW1lbWNweSgmcnFz
dHAtPnJxX2FkZHIsICZyZXEtPnJxX3hwcnQtPmFkZHIsIHJxc3RwLT5ycV9hZGRybGVuKTsK
QEAgLTE0OTksOCArMTUwMSw4IEBAIGJjX3N2Y19wcm9jZXNzKHN0cnVjdCBzdmNfc2VydiAq
c2Vydiwgc3RydWN0IHJwY19ycXN0ICpyZXEsCiAJc3ZjX2dldG5sKGFyZ3YpOwkvKiBDQUxM
RElSICovCiAKIAkvKiBQYXJzZSBhbmQgZXhlY3V0ZSB0aGUgYmMgY2FsbCAqLwotCXByb2Nf
ZXJyb3IgPSBzdmNfcHJvY2Vzc19jb21tb24ocnFzdHAsIGFyZ3YsIHJlc3YpOwotCXN2Y194
cHJ0X3B1dChycXN0cC0+cnFfeHBydCk7CisJcHJvY19lcnJvciA9IHN2Y19wcm9jZXNzX2Nv
bW1vbihycXN0cCwgYXJndiwgcmVzdiwgc194cHJ0LT54cHRfb3BzKTsKKwlzdmNfeHBydF9w
dXQoc194cHJ0KTsKIAogCWF0b21pY19pbmMoJnJlcS0+cnFfeHBydC0+YmNfZnJlZV9zbG90
cyk7CiAJaWYgKCFwcm9jX2Vycm9yKQpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9zdmNfeHBy
dC5jIGIvbmV0L3N1bnJwYy9zdmNfeHBydC5jCmluZGV4IDUxZDM2MjMwYjZlMy4uNTFkYTdj
MjQ0YmVlIDEwMDY0NAotLS0gYS9uZXQvc3VucnBjL3N2Y194cHJ0LmMKKysrIGIvbmV0L3N1
bnJwYy9zdmNfeHBydC5jCkBAIC00NjgsMTAgKzQ2OCwxMSBAQCBzdGF0aWMgc3RydWN0IHN2
Y194cHJ0ICpzdmNfeHBydF9kZXF1ZXVlKHN0cnVjdCBzdmNfcG9vbCAqcG9vbCkKICAqLwog
dm9pZCBzdmNfcmVzZXJ2ZShzdHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3RwLCBpbnQgc3BhY2UpCiB7
CisJc3RydWN0IHN2Y194cHJ0ICp4cHJ0ID0gcnFzdHAtPnJxX3hwcnQ7CisKIAlzcGFjZSAr
PSBycXN0cC0+cnFfcmVzLmhlYWRbMF0uaW92X2xlbjsKIAotCWlmIChzcGFjZSA8IHJxc3Rw
LT5ycV9yZXNlcnZlZCkgewotCQlzdHJ1Y3Qgc3ZjX3hwcnQgKnhwcnQgPSBycXN0cC0+cnFf
eHBydDsKKwlpZiAoeHBydCAmJiAoc3BhY2UgPCBycXN0cC0+cnFfcmVzZXJ2ZWQpKSB7CiAJ
CWF0b21pY19zdWIoKHJxc3RwLT5ycV9yZXNlcnZlZCAtIHNwYWNlKSwgJnhwcnQtPnhwdF9y
ZXNlcnZlZCk7CiAJCXJxc3RwLT5ycV9yZXNlcnZlZCA9IHNwYWNlOwogCg==
--------------2E3FA2AC8374D272B593860A--

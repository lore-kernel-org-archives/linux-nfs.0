Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9C69C282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:37:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A0EFE2083B
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:37:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726742AbfBEMh0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 07:37:26 -0500
Received: from foss.arm.com ([217.140.101.70]:40698 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726065AbfBEMh0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 07:37:26 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1973480D;
        Tue,  5 Feb 2019 04:37:26 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 733723F675;
        Tue,  5 Feb 2019 04:37:25 -0800 (PST)
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     Punit Agrawal <punit.agrawal@arm.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
 <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
 <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
 <65CE8FC5-3ADB-4E61-8127-70B979B037A0@redhat.com>
 <e99fd27b-9e60-22fc-af6b-da93b0e0ca0f@arm.com>
 <9C25D1F9-3A25-4CF3-822E-CE25829642D9@redhat.com>
From:   Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <fe7fb2ad-de9a-69a2-bd0e-9492e52b1be7@arm.com>
Date:   Tue, 5 Feb 2019 12:37:24 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <9C25D1F9-3A25-4CF3-822E-CE25829642D9@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------C632662A672DD5F43AA9547E"
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a multi-part message in MIME format.
--------------C632662A672DD5F43AA9547E
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi

On 05/02/2019 12:14, Benjamin Coddington wrote:
> On 5 Feb 2019, at 7:10, Cristian Marussi wrote:
> 
>> Hi Ben
>>
>> On 05/02/2019 11:53, Benjamin Coddington wrote:
>>> Hello Cristian and Punit,
>>>
>>> Did you ever get to the bottom of this one?  We just saw this on one 
>>> run
>>> of our 4.18.0-era ppc64le, and I'm wondering if we ever found the 
>>> root
>>> cause.
>>
>> unfortunately I stopped working actively on finding the root cause, 
>> since I've
>> found a viable workaround that let us unblock our broken LTP runs.
>>
>> Setting wsize=65536 in NFS bootparams completely solves the issue with 
>> 64k pages
>> (and does NOT break 4k either :D): this confirmed my hyp that there is 
>> some sort
>> of race when accounting refcounts during the lifetime of nfs_page 
>> structs which
>> leads to a misscounted refcount...but as I said I never looked back 
>> into that
>> again (but never say never...)
>>
>> Hope this helps...
> 
> Hmm, interesting..
> 
> Will you share your reproducer with me?  That will save me some time.

Sure.

My reproducer is the attached nfs_stress.sh script; when invoked with the
following params:

./nfs_stress.sh -w 10 -s 160000 -t 10

it leads to a crash within 10secs BUT ONLY with 64KB page Kconfig AND ONLY if
the above wsize workaround is NOT applied. (or the cleanup-code trick mentioned
in the emails) (the choice of the -s size parameter seemed sensible in determine
how quick it will die...)

BUT UNFORTUNATELY this was true ONLY when running on an AEMv8 FastModel (1-cpu
A53) (whose timings are much different from a real board); I've never been able
to reproduce reliably on real ARM64 silicon instead. (or on x86)
So all my debug and triage was made on the model once I was able to quickly
reproduce the same crash (and in fact the workaround worked then fine also on
silicon...)

On real silicon instead the only reproducer was a full LTP run: we had
consistent failures every night with the same exact refcount stacktrace (but
every time on a different LTP test as a trigger...being related to NFS activity
I suppose it's normal); since we applied the wsize workaround we saw no more
crashes.


Thanks

Regards

Cristian

> 
> Ben
> 


--------------C632662A672DD5F43AA9547E
Content-Type: application/x-shellscript;
 name="nfs_stress.sh"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs_stress.sh"

IyEvYmluL2Jhc2gKCnRyYXAgZG9fY2xlYW51cCBFWElUIDIgMyAxNQoKUElEUz0iIgpTVEFS
VD1gZGF0ZSArJXNgCkJBU0VfRElSPSIvcm9vdC9uZnNfdGVzdHMiCmV4cG9ydCBTVFVGRl9E
SVI9IiRCQVNFX0RJUi9zdHVmZiIKZXhwb3J0IExPR0ZJTEU9Ii9yb290L25mc19sb2cudHh0
IgoKZG9fa2lsbF9hbmRfY2xlYW51cCAoKQp7CglwaWQ9JDEKCWtpbGwgLTkgJHBpZCAmJiBl
Y2hvICIrJHBpZCsiCglybSAtcmYgJFNUVUZGX0RJUi9zdHVmZl8kcGlkCn0KCmRvX2NsZWFu
dXAgKCkKewoJZWNobyAiS2lsbGluZyBTeW5jZXIgJFNZTkNfUElEIiAmJiBraWxsIC05ICRT
WU5DX1BJRAoKCWVjaG8gLW4gIktpbGxpbmcgY2hpbGRyZW4gfCRQSURTfCAuLi4gIgoJZm9y
IHBpZCBpbiAkUElEUwoJZG8KCQlraWxsIC05ICRwaWQgJiYgZWNobyAkUElECglkb25lCglT
VE9QPWBkYXRlICslc2AKCWVjaG8gICIrIFdyaXRlcnM6ICRXUklURVJTICB+U1o6JFdSU1og
IC0tIFJ1biBmb3Igc2VjczogJCgoU1RPUC1TVEFSVCkpICBTeW5jIGV2ZXJ5OiAkU1lOQ0VS
X1RNIgoKCXRyYXAgLSBFWElUCgoJZXhpdCAwCn0KCmRvX3J1bl9zeW5jZXIgKCkKewoJc2xl
cHQ9JDEKCS9iaW4vYmFzaCAtYyAid2hpbGUgdHJ1ZTtkbyBzbGVlcCAkc2xlcHQgJiYgc3lu
Yztkb25lIiAmCglTWU5DX1BJRD0kIQoJZWNobyAiU3luY2VyIHJ1bm5pbmcgUElEOiRTWU5D
X1BJRCAuLi4gZXZlcnkgJHNsZXB0IHNlY3MuLi4iCn0KCmRvX3NwYXduX3dyaXRlciAoKQp7
CgkjIEJhc2Ugc2l6ZSAuLi4gaXQgd2lsbCBiZSByYW5kb21seSBpbmNyZWFzZWQgYnkgYSA8
NGtiIHF1YW50aXR5Cgl3c3o9JDEKCSMjIHRha2VzIDIuNSBzZWNzIHRvIHdyaXRlIGFuZCBz
eW5jIDhNQgoJL2Jpbi9iYXNoIC1jICd3aGlsZSB0cnVlO2RvIEJTPSQoKCR7MH0gKyAkUkFO
RE9NIC8gMTApKSA7IE9GPSRTVFVGRl9ESVIvc3R1ZmZfJHtCQVNIUElEfSA7IGRkIGlmPS9k
ZXYvdXJhbmRvbSBvZj0kT0YgYnM9JEJTIGNvdW50PTEgMj4vZGV2L251bGwgJiYgc2xlZXAg
MC4zO2RvbmUnICR3c3ogJgoJd3BpZD0kIQoJUElEUz0iJFBJRFMgJHdwaWQiCgllY2hvICIt
PiBTdGFydGVkIHdyaXRlciBQSUQgJHdwaWQgdG8gZmlsZSAkU1RVRkZfRElSL3N0dWZmXyR3
cGlkIgp9Cgpkb190aHVuZGVyaW5nX2hlcmQgKCkKewoJd251bT0kMQoJd3N6PSQyCgoJZWNo
byAiU3Bhd25pbmcgJHdudW0gd3JpdGVycy4uLiIKCglmb3IgaSBpbiBgc2VxIDAgJHdudW1g
CglkbwoJCWRvX3NwYXduX3dyaXRlciAkd3N6CgkJc2xlZXAgMC4wMQoJZG9uZQp9CgoKZG9f
aWRsZSAoKQp7Cgl3c3o9JDEKCXZpY3RpbXM9JDIKCgllY2hvIC1uICI9PT0+Pj4gSlVTVCBJ
ZGxpbmcuLi5raWxsaW5nIHBlcmlvZGljYWxseSAkdmljdGltcyB3cml0ZXJzLi4uIgoJd2hp
bGUgdHJ1ZQoJZG8KCQljbnQ9MAoJCW5ld3BpZHM9IiIKCQlzbGVlcCAxMCAmJiBlY2hvIC1u
ICIuIgoJCWZvciBwaWQgaW4gJFBJRFMKCQlkbwoJCQlpZiBbICRjbnQgLWx0ICR2aWN0aW1z
IF0KCQkJdGhlbgoJCQkJZG9fa2lsbF9hbmRfY2xlYW51cCAkcGlkCgkJCQljbnQ9JCgoY250
KzEpKQoJCQllbHNlCgkJCQluZXdwaWRzPSIkbmV3cGlkcyAkcGlkIgoJCQlmaQoJCWRvbmUK
CQkjIyBjb3B5IHN1cnZpdm9ycwoJCVBJRFM9JG5ld3BpZHMKCQkjIyAuLiBhbmQgcmVzcGF3
bgoJCWZvciBpIGluIGBzZXEgMCAkKChjbnQtMSkpYAoJCWRvCgkJCWRvX3NwYXduX3dyaXRl
ciAkd3N6CgkJZG9uZQoJZG9uZQp9CgojIyBtYWluCldSSVRFUlM9MTAwCldSU1o9ODE5MgpT
WU5DRVJfVE09MQoKZWNobyAiQ2xlYW5pbmcgdXAgJFNUVUZGX0RJUiIgJiYgcm0gLXJmICIk
U1RVRkZfRElSIiAmJiBta2RpciAtcCAkU1RVRkZfRElSCnN5bmMKCndoaWxlIGdldG9wdHMg
Inc6czp0OiIgb3B0aW9uCmRvCgljYXNlICRvcHRpb24gaW4KCQkidyIpCgkJCVdSSVRFUlM9
JE9QVEFSRwoJCQk7OwoJCSJzIikKCQkJV1JTWj0kT1BUQVJHCgkJCTs7CgkJInQiKQoJCQlT
WU5DRVJfVE09JE9QVEFSRwoJCQk7OwoJCSopCgkJCWVjaG8gIlVzYWdlICQwIC13IDxudW1f
d3JpdGVycz4gLXMgPHdyX3NpemU+IC10IDxzeW5jZXJfcGVyaW9kPiIKCQkJZXhpdCAxCgkJ
CTs7Cgllc2FjCmRvbmUKCmRvX3J1bl9zeW5jZXIgJFNZTkNFUl9UTSAmJiBzbGVlcCAxCgpk
b190aHVuZGVyaW5nX2hlcmQgJFdSSVRFUlMgJFdSU1oKCmRvX2lkbGUgJFdSU1ogJCgoV1JJ
VEVSUyAvIDEwKSkKCg==
--------------C632662A672DD5F43AA9547E--

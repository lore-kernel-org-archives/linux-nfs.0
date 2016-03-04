Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36771 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760170AbcCDWHr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 17:07:47 -0500
Received: by mail-qg0-f51.google.com with SMTP id u110so54902628qge.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Mar 2016 14:07:47 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 4 Mar 2016 14:07:46 -0800
Message-ID: <CALd+sgeAV5fHKHjqmWcu5zGS=y3475-ZO60vQ4JGuqUkfU0LWQ@mail.gmail.com>
Subject: SUNRPC hangs trying to use srcport which is in TIME_WAIT from
 previous connection.
From: Alexey Makhalov <makhaloff@gmail.com>
To: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: multipart/mixed; boundary=001a11c121fe575186052d4058f3
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--001a11c121fe575186052d4058f3
Content-Type: text/plain; charset=UTF-8

To reproduce it just do mount/umount in a loop.
Script and patch (for linux v4.2) are attached.

 Thanks
--Alexey

--001a11c121fe575186052d4058f3
Content-Type: application/x-sh; name="loop.sh"
Content-Disposition: attachment; filename="loop.sh"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ile92oou0

IyEgL2Jpbi9iYXNoCgpORlMzX1NIQVJFPQoKbWF4PTAKZGVjbGFyZSAtYSBkPSgpCgpmb3IgaSBp
biB7MS4uMTAwfTsKZG8KClNUQVJUVElNRT0kKGRhdGUgKyVzKQplY2hvICRpCm1vdW50Lm5mcyAk
TkZTM19TSEFSRSAvbW50L25mcyAtdiAtcncgLW8gbm9leGVjLHZlcnM9MwoKRU5EVElNRT0kKGRh
dGUgKyVzKQp0aW1lPSQoKCRFTkRUSU1FIC0gJFNUQVJUVElNRSkpIApkdGltZT1gZWNobyAke2Rb
JHRpbWVdOi0wfWAKbGV0ICJkWyR0aW1lXT0kZHRpbWUrMSIKaWYgWyAkbWF4IC1sdCAkdGltZSBd
IDsgdGhlbgogICAgbWF4PSR0aW1lCmZpCmVjaG8gIkl0IHRvb2sgJHRpbWUgc2Vjb25kcyB0byBj
b21wbGV0ZSB0aGlzIHRhc2suIE1heDogJG1heCIKCnVtb3VudCAvbW50L25mcwpkb25lCgplY2hv
IE1heGltdW0gJG1heCBzZWNvbmRzCmZvciBpIGluIGBzZXEgMCAkbWF4YCA7CmRvCiAgICB0aW1l
PSR7ZFtpXX0KICAgIGlmIFsgLW4gIiR0aW1lIiBdOyB0aGVuCiAgICAgICAgZWNobyAkaTogJHRp
bWUKICAgIGZpCmRvbmUK
--001a11c121fe575186052d4058f3
Content-Type: text/x-diff; charset=US-ASCII;
	name="SUNRPC-Do-not-reuse-srcport-for-TIME_WAIT-socket.patch"
Content-Disposition: attachment;
	filename="SUNRPC-Do-not-reuse-srcport-for-TIME_WAIT-socket.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ile92wrm1

ZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydHNvY2suYyBiL25ldC9zdW5ycGMveHBydHNvY2su
YwppbmRleCBjMzUwMzg1Li5hNzEyMzNmIDEwMDY0NAotLS0gYS9uZXQvc3VucnBjL3hwcnRzb2Nr
LmMKKysrIGIvbmV0L3N1bnJwYy94cHJ0c29jay5jCkBAIC0yMjQzLDYgKzIyNDMsNyBAQCBzdGF0
aWMgdm9pZCB4c190Y3Bfc2V0dXBfc29ja2V0KHN0cnVjdCB3b3JrX3N0cnVjdCAqd29yaykKIAkJ
LyogV2UncmUgcHJvYmFibHkgaW4gVElNRV9XQUlULiBHZXQgcmlkIG9mIGV4aXN0aW5nIHNvY2tl
dCwKIAkJICogYW5kIHJldHJ5CiAJCSAqLworCQl0cmFuc3BvcnQtPnNyY3BvcnQgPSAwOwogCQl4
c190Y3BfZm9yY2VfY2xvc2UoeHBydCk7CiAJCWJyZWFrOwogCWNhc2UgMDoK
--001a11c121fe575186052d4058f3--

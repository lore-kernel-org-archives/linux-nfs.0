Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3563C10F00
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 00:46:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE2A620663
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 00:46:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B2klowCJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726120AbfCGAqf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 19:46:35 -0500
Received: from mail-lf1-f50.google.com ([209.85.167.50]:43967 "EHLO
        mail-lf1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726134AbfCGAqe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 19:46:34 -0500
Received: by mail-lf1-f50.google.com with SMTP id a130so2445176lfa.10
        for <linux-nfs@vger.kernel.org>; Wed, 06 Mar 2019 16:46:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=p/WcP2VT4rHCJICumg94OXjq4BT22Ykww0DFbQc7QX0=;
        b=B2klowCJJ8ybztP91bxqMIoWlB7x+JDo3lMJ4ja6vGBdckN8uwgwGuv+NqTW9Z8wSJ
         N8tGgYUcEV08KV0EojjxLyvLwBCytsiuHCYSmg37h67x4+m6Ef9x3etPXjYPwIuVDq9G
         hKtuB8tVA0HwoXclwGLHyCSRJTfWeLZuVKI3YE7yt3fYqwxCvXIPXMRhtkYUVJbEint/
         Uk9hYCXxbM0FLLX2vCMYk3cS8rRvg+gW6SXM6b0JzJeogV0/2ez+8FyOrIOe2PSKaamN
         ymzyzZzlGd1nQaRZaXNi2TA7T/TjiK8yveiCN0k0FF/s5NOP9FwNya8j5S8R2J0+fDfQ
         nEtw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=p/WcP2VT4rHCJICumg94OXjq4BT22Ykww0DFbQc7QX0=;
        b=sjKgxnEOeBsf5FeA3wZfuiVNQ19YAxG2klmkKIEmemDeMLIj1a3S3/1wIvSvSqhdXs
         iMrQdlXnMvRkgho710mXYGOi48IGo/BxU+si9IDvj29ezb10CBrxJydMHspbxj38WcIV
         B14/WbmMVl2ZPSWmBmx7bxwKW4poBE7ZTHPRHpb58a1PTeJFSRhMhjJkHwDwN5sy/+42
         XIPKerGJgsSBQbXSNEws59s7fqomNnCwdzK7gruZ+Amqds3LyY2GaRiciKNAfSUBP1ZH
         QlMMIkh8QwzoOkn1PRA+96yGMV7Y1N8AFc3Ip4gYsvtYR81q2rMPclyViU6luY0HNn9A
         s9EA==
X-Gm-Message-State: APjAAAW221eaHUSGOo7CrgdF+v6QSCUvyftz2585WDjRKoMTptMZa8Rh
        0Le0Vbd8RBitp0dBxlBuvopeT5GhRisoT4eoXosX8twe
X-Google-Smtp-Source: APXvYqyPObw84+aq29vSUJujNQbdL7BEwcBnyr57+L0dVMgsgRExyjqd1ZcTxlL3SYAXrC7oPFT+acb0LoBOPVN8kHA=
X-Received: by 2002:ac2:424e:: with SMTP id m14mr5399777lfl.4.1551919592135;
 Wed, 06 Mar 2019 16:46:32 -0800 (PST)
MIME-Version: 1.0
From:   Richard Sharpe <realrichardsharpe@gmail.com>
Date:   Wed, 6 Mar 2019 16:46:04 -0800
Message-ID: <CACyXjPwSWO53oFhGDowUSzO0qVPjq3JNWdGDN2BO5guBMX+dyQ@mail.gmail.com>
Subject: Patch: Provide the offending UID/GID/name for which mapping fails we
 can debug the reasons
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: multipart/mixed; boundary="0000000000000277af0583767074"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--0000000000000277af0583767074
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi folks,

It is annoying to see these messages in /var/log/messages:

2019-03-04 23:15:23 nfsidmap[25468]: name_lookup: nfs4_gid_to_name:
failed: Unknown error -2

because you have no idea what UID/GID/name failed.

Attached is a git-format-patch patch to add the additional info to
those error messages.

It does not add any new messages.

Let me know what you think.

--=20
Regards,
Richard Sharpe
(=E4=BD=95=E4=BB=A5=E8=A7=A3=E6=86=82=EF=BC=9F=E5=94=AF=E6=9C=89=E6=9D=9C=
=E5=BA=B7=E3=80=82--=E6=9B=B9=E6=93=8D)(=E4=BC=A0=E8=AF=B4=E6=9D=9C=E5=BA=
=B7=E6=98=AF=E9=85=92=E7=9A=84=E5=8F=91=E6=98=8E=E8=80=85)

--0000000000000277af0583767074
Content-Type: application/octet-stream; 
	name="0001-Provide-the-offending-UID-GID-name-for-which-mapping.patch"
Content-Disposition: attachment; 
	filename="0001-Provide-the-offending-UID-GID-name-for-which-mapping.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jsxwqjq70>
X-Attachment-Id: f_jsxwqjq70

RnJvbSBhZGNiYjA0YjVlZDZiMDU2NTY2Mjg1Mzk1YTkzZDFmOWNjMTU1NzIwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSaWNoYXJkIFNoYXJwZSA8cmVhbHJpY2hhcmRzaGFycGVAZ21h
aWwuY29tPgpEYXRlOiBUdWUsIDUgTWFyIDIwMTkgMjM6NDY6MDMgKzAwMDAKU3ViamVjdDogW1BB
VENIXSBQcm92aWRlIHRoZSBvZmZlbmRpbmcgVUlEL0dJRC9uYW1lIGZvciB3aGljaCBtYXBwaW5n
IGZhaWxzIHNvCiB3ZSBjYW4gZGVidWcgd2hhdCBpcyBnb2luZyBvbi4KCi0tLQogdXRpbHMvbmZz
aWRtYXAvbmZzaWRtYXAuYyB8IDEwICsrKysrKy0tLS0KIDEgZmlsZSBjaGFuZ2VkLCA2IGluc2Vy
dGlvbnMoKyksIDQgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvdXRpbHMvbmZzaWRtYXAvbmZz
aWRtYXAuYyBiL3V0aWxzL25mc2lkbWFwL25mc2lkbWFwLmMKaW5kZXggZDM5NjdhMy4uZmMwMGRh
NyAxMDA2NDQKLS0tIGEvdXRpbHMvbmZzaWRtYXAvbmZzaWRtYXAuYworKysgYi91dGlscy9uZnNp
ZG1hcC9uZnNpZG1hcC5jCkBAIC0yMDUsOCArMjA1LDkgQEAgc3RhdGljIGludCBpZF9sb29rdXAo
Y2hhciAqbmFtZV9hdF9kb21haW4sIGtleV9zZXJpYWxfdCBrZXksIGludCB0eXBlKQogCQlzcHJp
bnRmKGlkLCAiJXUiLCBnaWQpOwogCX0KIAlpZiAocmMgPCAwKSB7Ci0JCXhsb2dfZXJybm8ocmMs
ICJpZF9sb29rdXA6ICVzOiBmYWlsZWQ6ICVtIiwKLQkJCSh0eXBlID09IFVTRVIgPyAibmZzNF9v
d25lcl90b191aWQiIDogIm5mczRfZ3JvdXBfb3duZXJfdG9fZ2lkIikpOworCQl4bG9nX2Vycm5v
KHJjLCAiaWRfbG9va3VwOiAlczogZm9yICVzIGZhaWxlZDogJW0iLAorCQkJKHR5cGUgPT0gVVNF
UiA/ICJuZnM0X293bmVyX3RvX3VpZCIgOiAibmZzNF9ncm91cF9vd25lcl90b19naWQiKSwKKwkJ
CW5hbWVfYXRfZG9tYWluKTsKIAkJcmV0dXJuIEVYSVRfRkFJTFVSRTsKIAl9CiAKQEAgLTI2Miw4
ICsyNjMsOSBAQCBzdGF0aWMgaW50IG5hbWVfbG9va3VwKGNoYXIgKmlkLCBrZXlfc2VyaWFsX3Qg
a2V5LCBpbnQgdHlwZSkKIAkJcmMgPSBuZnM0X2dpZF90b19uYW1lKGdpZCwgZG9tYWluLCBuYW1l
LCBJRE1BUF9OQU1FU1opOwogCX0KIAlpZiAocmMpIHsKLQkJeGxvZ19lcnJubyhyYywgIm5hbWVf
bG9va3VwOiAlczogZmFpbGVkOiAlbSIsCi0JCQkodHlwZSA9PSBVU0VSID8gIm5mczRfdWlkX3Rv
X25hbWUiIDogIm5mczRfZ2lkX3RvX25hbWUiKSk7CisJCXhsb2dfZXJybm8ocmMsICJuYW1lX2xv
b2t1cDogJXM6IGZvciAldSBmYWlsZWQ6ICVtIiwKKwkJCSh0eXBlID09IFVTRVIgPyAibmZzNF91
aWRfdG9fbmFtZSIgOiAibmZzNF9naWRfdG9fbmFtZSIpLAorCQkJKHR5cGUgPT0gVVNFUiA/IHVp
ZCA6IGdpZCkpOwogCQlyZXR1cm4gRVhJVF9GQUlMVVJFOwogCX0KIAotLSAKMS44LjMuMQoK
--0000000000000277af0583767074--

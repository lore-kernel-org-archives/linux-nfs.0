Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E37FEC43381
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 01:17:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9FB5020684
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 01:17:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LiWlODXO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726010AbfCGBRf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 20:17:35 -0500
Received: from mail-lf1-f41.google.com ([209.85.167.41]:35676 "EHLO
        mail-lf1-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725793AbfCGBRf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 20:17:35 -0500
Received: by mail-lf1-f41.google.com with SMTP id h6so6150225lfc.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Mar 2019 17:17:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=ETCuC8/d+5bieSZQ9/sx3gJJPzz/wF/kfSa4QrL8zkk=;
        b=LiWlODXOOQFhwpscYZ4eemZA5du1N8RcEThPDjd4fKL5Yv+JsKjrzkA5eQbmEwlQzE
         lCg/B9plKVzotOw4kaJcT8pWxCRrdaTwcRlN27uqjt5AIvcg00f7U2aOF94jlBTJhkyM
         /4+kFSDkYqXnK/Sxfk5hefkkoK5cbrVYOGl8XgGlaPD2HzBMWk/q38r7uHTw+KUqoMHw
         3nhk3Wuk1/aX5fskJkpzjYcR4xYo7ucTzHiYTTFBC9yNJL1ldfKF2uhOs0xOd2Ws2OAs
         6wXhljI1TS72JiHpGPmG0Fjbzv97x+GulgirhFEQZdKlo3yEwnvRCKvtN9jqARRJu3Ka
         iApQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=ETCuC8/d+5bieSZQ9/sx3gJJPzz/wF/kfSa4QrL8zkk=;
        b=Lw8LhpEjow09pSUKL3/yBYJNaYGCi9ObzmyYYwamU8I873mpO8DMDi9IO2pgO/TtO2
         tMFyobLtjyDO48ecWwjTLg+sOcyP1z279ctb88hv50zH15yqMAr+uPh6niUmv8kg5+7o
         TdbMOXrPYCm8a3XtswnqK7Z6Ffj6oFEVkQg7PMHVrN6RX9QKW9Z6ewNk0C0taWVRzgZI
         k8K9Gv8WeD88ZCU+/7xyj+2uQqnpwP2IFNqihtqotFG4/sDcptdpjCd/+XAMVl4Rj2qK
         bzKk0c2m24ZUCFKsXSLAsQ+2VMmpSi34UamUjPEoq9cjNl2lFkbYfhDhtxiFoLsDMcgx
         GKaQ==
X-Gm-Message-State: APjAAAU+BEOxMXLD5oSF4a9NTAb71YYW7qA7AKy5u931VN2kfJ1wjzyA
        zSO9ZMRNaGQeyrJ4gRzhuTvLNkcAYtIrx72prMK/2g==
X-Google-Smtp-Source: APXvYqwKIciM6cMNX4dzs4Gi0GclDzdEl5ECDrWCV1m4JIs65tse4itx8x1SISVlxKXfa9NyK2fNu9o0etpdMVhenes=
X-Received: by 2002:a19:f506:: with SMTP id j6mr5308838lfb.159.1551921453135;
 Wed, 06 Mar 2019 17:17:33 -0800 (PST)
MIME-Version: 1.0
From:   Richard Sharpe <realrichardsharpe@gmail.com>
Date:   Wed, 6 Mar 2019 17:17:04 -0800
Message-ID: <CACyXjPx84Y9jwrAQzvhjDz2jH8aZnx8MsvJjQvW9FzDfZy0HCQ@mail.gmail.com>
Subject: Check that an RPC compiler has been installed
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: multipart/mixed; boundary="000000000000ef189e058376decd"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--000000000000ef189e058376decd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

When I installed Fedora-29 to check out building on Fedora I didn't
have rpcgen installed.

autogen worked and configure worked but make failed in spectacular ways.

The attached patch warns the user during configure but is perhaps not
the correct test, because of rpcgen is on your path but not where the
earlier tests expect it, things will still likely fail.

--=20
Regards,
Richard Sharpe
(=E4=BD=95=E4=BB=A5=E8=A7=A3=E6=86=82=EF=BC=9F=E5=94=AF=E6=9C=89=E6=9D=9C=
=E5=BA=B7=E3=80=82--=E6=9B=B9=E6=93=8D)(=E4=BC=A0=E8=AF=B4=E6=9D=9C=E5=BA=
=B7=E6=98=AF=E9=85=92=E7=9A=84=E5=8F=91=E6=98=8E=E8=80=85)

--000000000000ef189e058376decd
Content-Type: application/octet-stream; 
	name="0001-Check-that-a-version-of-rpcgen-has-been-installed-an.patch"
Content-Disposition: attachment; 
	filename="0001-Check-that-a-version-of-rpcgen-has-been-installed-an.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jsxxy08m0>
X-Attachment-Id: f_jsxxy08m0

RnJvbSA0YzU0ZmU2YTlmM2M3MWUyNjAyMjEzZWQ4YjE2MTEyMTM2YTYwYjIzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiByb290IDxyb290QGxvY2FsaG9zdC5sb2NhbGRvbWFpbj4KRGF0
ZTogV2VkLCA2IE1hciAyMDE5IDE5OjUxOjEyIC0wNTAwClN1YmplY3Q6IFtQQVRDSF0gQ2hlY2sg
dGhhdCBhIHZlcnNpb24gb2YgcnBjZ2VuIGhhcyBiZWVuIGluc3RhbGxlZCBhbmQgZXhpc3RzLgog
SWYgbm90LCBsZXQgdGhlIHVzZXIga25vdyBhYm91dCBpdCByYXRoZXIgdGhhbiBnZXR0aW5nIGFu
IGVycm9yIGxhdGVyIGR1cmluZwogbWFrZS4KCi0tLQogY29uZmlndXJlLmFjIHwgNCArKysrCiAx
IGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvY29uZmlndXJlLmFj
IGIvY29uZmlndXJlLmFjCmluZGV4IGNiOWQ5MjEuLjM0MWRiZGMgMTAwNjQ0Ci0tLSBhL2NvbmZp
Z3VyZS5hYworKysgYi9jb25maWd1cmUuYWMKQEAgLTE1NCw2ICsxNTQsMTAgQEAgQUNfQVJHX1dJ
VEgocnBjZ2VuLAogCWlmIHRlc3QgIiRycGNnZW5fcGF0aCIgPSAieWVzIjsgdGhlbgogCSAgICBm
b3IgcCBpbiAvdXNyL2xvY2FsL2Jpbi9ycGNnZW4gL3Vzci9iaW4vcnBjZ2VuIC9iaW4vcnBjZ2Vu
CiAJICAgIGRvIGlmIHRlc3QgLWYgJHAgOyB0aGVuIFJQQ0dFTl9QQVRIPSRwIDsgYnJlYWs7IGZp
IDsgZG9uZQorCSAgICBpZiB0ZXN0IC16ICIkUlBDR0VOX1BBVEgiOyB0aGVuCisJCSBBQ19DSEVD
S19QUk9HKFJQQ0dFTl9GT1VORCwgW3JwY2dlbl0sIFtycGNnZW5dLCBbbm9dKQorCQkgdGVzdCAi
JFJQQ0dFTl9GT1VORCIgPT0gIm5vIiAmJiBBQ19NU0dfRVJST1IoW1BsZWFzZSBpbnN0YWxsIHJw
Y2dlbl0pCisJICAgIGZpCiAJZWxpZiB0ZXN0ICIkcnBjZ2VuX3BhdGgiICE9ICJpbnRlcm5hbCI7
IHRoZW4KIAkgICAgUlBDR0VOX1BBVEg9JHJwY2dlbl9wYXRoCiAJZWxzZQotLSAKMi4xOS4xCgo=
--000000000000ef189e058376decd--

Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78AA6C282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 17:06:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52F362184C
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 17:06:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726152AbfAWRGc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 12:06:32 -0500
Received: from mx2.suse.de ([195.135.220.15]:60674 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725896AbfAWRGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Jan 2019 12:06:32 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 4CD12B10D;
        Wed, 23 Jan 2019 17:06:30 +0000 (UTC)
Subject: Re: [PATCH] xprtrdma: Make sure Send CQ is allocated on an existing
 CPU
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
References: <3f5da1e4-99f1-8376-a291-e50a7d52c303@suse.com>
 <BF1A6DC0-FF34-4B80-8602-6B122AD5ABFD@oracle.com>
From:   Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.de>
Openpgp: preference=signencrypt
Autocrypt: addr=nmoreychaisemartin@suse.de; prefer-encrypt=mutual; keydata=
 xsBNBFjZETwBCADEkoe7QWAXzd9xpSiPbQK6P2F4wKdxyTp6r0aN4I0O+4fc8xWXvmwOrCjF
 UsuoGZ3CxJaHgdB/3ueW/IhMO5Ldz7pylhKVlG/moUh4CBK2eRUdaG7mHID01GyJMtR3VQqu
 22hJhHPYy0erpYViyr+I4MzQA9QZLoQhSxn4imjZOZPcj20JE+lRfXppNv9g7vQiRLMcXjTi
 KcnrqG5owOi6Cn1sZ201YfdeztGxKA+jvjWO+6absTTlorIlZNGUf85s2+caGDsqa31u2DPs
 hVv5UUTy1g/5aP2wacSWI3Qm4n2MWl1aCnHN2h737PCXXfBk5iGJsgBUnSQULgdgEAt1ABEB
 AAHNO05pY29sYXMgTW9yZXktQ2hhaXNlbWFydGluIDxuaWNvbGFzQG1vcmV5LWNoYWlzZW1h
 cnRpbi5jb20+wsCOBBMBCAA4FiEEQtJThcGhwCuLGxxvgBvduCWYj2QFAltPP2wCGwMFCwkI
 BwIGFQoJCAsCBBYCAwECHgECF4AACgkQgBvduCWYj2QOPQgAq99w9BuzV6ahqg05g3gnl2XR
 bjvn3zY5DLIU6W1zda5DYNO3lL14ii92MhWYAncfpqDNoTO2idDXXO4BvGiEY6+DK2liYt7R
 +Q1iNJfCnv5Oeh/dmaCxzbYsBV3EYqimZvGer7jxyS+wThAvE7jzMSDOzhjd0K+KWIycNDRB
 V0kycGwcFf/mvsZxORI8LEHFsaKRQXJ22ilubaAU9byF/gvp7fjlfWlKaL2H2OP7d9a2asbK
 x2A+KHQfGSOy3lkjlXDz90IOXkKvpFm5ZQMFoFxMdL0KZIAu7Lu34LNtZ9FhWfNsKo3r3u7q
 9oXP9mtJpCs9yGtK36RhSKiqf2Ud1c7ATQRY2RE8AQgAvcwMwkZU4M8jvbIlS0GMG0VIXC9U
 1CVPxYjkFkE5i97g3QXOjIFQbPoafNkcD22107+FuK4IQWDynZhV70Tfo7xgy6tX9obLgkoh
 NXJEzMxVfrCqFkSBAtdrRKcOZ3BBRpvtZP6yUS5PXh8bqp/skYz68jfAiurSuPm+LWdrqypT
 9vVxvk95f5m1EqKn46r8nimluscO5LvPRF9l6EFj/6ZvdkcVHelQ1Pb6VVv0+6j2UZdMLVJw
 5ztsHj6GZr1HxK+TrIdzDb5tZshvr+BFdh4L2jU+qWtuyKba1KtOnAOnQ7CCsD7TLk4SUKfP
 8bpoJeUPQPxK0KCU6wfa3JSJuwARAQABwsBfBBgBAgAJBQJY2RE8AhsMAAoJEIAb3bglmI9k
 MDcH/3jiKRQeu3CqFCb3JtyVnL52oGTrsmrAsMcB/WtKPYzkXKvp7CaMp0vw6Y1ChsmWoMu/
 he7Aaxe18dHFxdn+QaONlzTYkAxOT/1S8L4J/etgCd6tHaeDu6ECPFIDZnbKHEITWgRxwqDm
 myxq4DaGw02iwXm/c2jmas/AgbgImdG1QARKYOdIQxGEx6eIwoFqWnYQLKf3goJvd03PmPnt
 X6rRNxZqDi8coRWunr4Z9ENYl9JAmrDGcJc7Hs6i2Y0zNSqKp+vlCB1xN0GlC8hSg9Rg4YrF
 8cqJTgej9k17Mn74rWHSGdwgrSOz1Q8c5l9l5JLxM/WzLUraDKbHvagLJh0=
Message-ID: <18bbe249-7d03-2475-d943-2f7d386a3797@suse.de>
Date:   Wed, 23 Jan 2019 18:06:25 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <BF1A6DC0-FF34-4B80-8602-6B122AD5ABFD@oracle.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="E1lOAR08MMOxfHFZRyJkhLqp8G02aQnAr"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--E1lOAR08MMOxfHFZRyJkhLqp8G02aQnAr
Content-Type: multipart/mixed; boundary="3eYxmqVNL6VA7zHrDWqYTsWcqJcs6xiBU";
 protected-headers="v1"
From: Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
 linux-rdma@vger.kernel.org
Message-ID: <18bbe249-7d03-2475-d943-2f7d386a3797@suse.de>
Subject: Re: [PATCH] xprtrdma: Make sure Send CQ is allocated on an existing
 CPU
References: <3f5da1e4-99f1-8376-a291-e50a7d52c303@suse.com>
 <BF1A6DC0-FF34-4B80-8602-6B122AD5ABFD@oracle.com>
In-Reply-To: <BF1A6DC0-FF34-4B80-8602-6B122AD5ABFD@oracle.com>

--3eYxmqVNL6VA7zHrDWqYTsWcqJcs6xiBU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: fr



On 1/23/19 5:51 PM, Chuck Lever wrote:
> Hi Nicolas-
>
>> On Jan 23, 2019, at 8:12 AM, Nicolas Morey-Chaisemartin <nmoreychaisem=
artin@suse.com> wrote:
>>
>> Make sure host has at least 2 CPU before allocating to CPU#1
> The fourth parameter of ib_alloc_cq() is not a CPU number,
> it's a completion vector number. What failure did you see
> that prompted this patch?
When trying to mount, I get this:
+ mount -o rdma,port=3D20049 192.168.20.15:/tmp/RAM /tmp/RAM
mount.nfs: mounting 192.168.20.15:/tmp/RAM failed, reason given by server=
: No such file or directory

Digging a bit into the code, it appears that the cq allocation here retur=
ns a ENOENT which come from mlx5_vector2eqn.
On my system (VM with a mlx5 card with SRIOV), the comp_eqs_list only con=
tains one entry with index =3D=3D 0

Nicolas


--3eYxmqVNL6VA7zHrDWqYTsWcqJcs6xiBU--

--E1lOAR08MMOxfHFZRyJkhLqp8G02aQnAr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEQtJThcGhwCuLGxxvgBvduCWYj2QFAlxInxEACgkQgBvduCWY
j2TJVwf/cIHyupCWAsJEIzUj8UWcLuUUEho36qAWzgj18Dm1IyjlGS9iFiNYHMKj
M5plxAbALcT/P4AMCD7LjGX8NpK4+4PUJkmoVUR/Tzhw79Mq1rnaEfQirE/l+BMi
rN7nu9Yw6FFpYOOHMjV1ky0aevur7Oy72nrcnDbUj8dtwKgJamXX9F8H6VqrP+fY
yWmMRHRnHBRP6/qroMNL/7u+fMZNcFtzRqmQBFPNZ1jGKWpoKp/hpY7xiS8CzoiU
6XNsaeSEHs4dgfSlyc/06osCg+XLYOFto5S1D7xyVXyHZNB4iL9zBnTXcefdESDZ
6gi6Cb44Z3r3xvtb81MIImLeoWCQmQ==
=KqOZ
-----END PGP SIGNATURE-----

--E1lOAR08MMOxfHFZRyJkhLqp8G02aQnAr--

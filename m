Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BF5EC43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 03:52:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7DF62082F
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 03:52:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7DF62082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726972AbeK1OwU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 09:52:20 -0500
Received: from mx2.suse.de ([195.135.220.15]:38328 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726894AbeK1OwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 09:52:19 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 85326AF70;
        Wed, 28 Nov 2018 03:52:11 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Wed, 28 Nov 2018 14:52:03 +1100
Subject: [PATCH nfs-utils] systemd/rpc-statd.service - add IgnoreOnIsolate=yes
cc:     linux-nfs@vger.kernel.org
Message-ID: <87bm69q2os.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you run
  systemctl isolate multi-user.target
then all services not needed by multi-user.target are stopped.
This currently includes rpc-statd, which is a problem.

Systemd doesn't know that rpc-statd.service is needed by
multi-user.target, or more accurately nfs-client.target, because
sometimes it isn't.
It is started dynamically by mount.nfs when a v3 or v2 filesystem
is mounted (not when v4 is mounted) - so systemd doesn't see the connection.

mount units default to IgnoreOnIsolate=3Dyes, as mounts are expected to be
left mounted when you run "systemctl isolate ....".  As rpc-statd.service
is started by a mount, and needed for some mounts, it makes sense for it
to declare IgnoreOnIsolate=3Dyes too.
With this declaration in place rpc.statd remains running when
  systemctl isolate multi-user.target
is run.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 systemd/rpc-statd.service | 1 +
 1 file changed, 1 insertion(+)

diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index f41ae2084f3c..1f4e6a8b92ab 100644
=2D-- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -7,6 +7,7 @@ Wants=3Dnetwork-online.target
 After=3Dnetwork-online.target nss-lookup.target rpcbind.socket
=20
 PartOf=3Dnfs-utils.service
+IgnoreOnIsolate=3Dyes
=20
 [Service]
 Environment=3DRPC_STATD_NO_NOTIFY=3D1
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlv+EOQACgkQOeye3VZi
gbmllA/+OjRxTn6uDkdTFucc+N6zzfXmNQj9k+ijRR90YmLeg6ro2FjfTzpb51CC
Nzxegc47xsXZIbUEgCbCkMBFGralv/83k/JXmBU+ivb/UgPi3nuVECwGhNOEfgku
bir2JJyUMH6VyffoWVzznlwIoCQ+/vdkOEm3U8o1m4ja0cit/0P982dgq9LFsCNt
jKTEp+Sj8ren8QN3NNbuyS0rOaIzhuTLURqsBHrZUvlYun6JBgaAVQfLB8rfrW98
DmPOGlawV5dkI1TQgt2qX0rHHmym/Gb+57j9IvoU+5neSSncsH862T2+itfNm8td
8pn6Jdk6o6GDB1phusH+JHJV7S4cInajJLAGapRtqBhFS3C4ZjHEBfc5lyf1m3zc
/Tvoa2obKpSBxLU/RTAHU+zyDYPAIzItHYa1Xcph2r0oadBOuZMpN5oUkJTNOO38
dUXSeFb8z6EfbHz4Gf5g6O0vYwFYGvH65lCgMu8NJLyyBbiYVasegzQX1dHq6+Mq
6GyBXGdEaWODYca6hPw+aytZtXuFONikqoa/J6qIwNt7scEwKVRJn5zuQdislSt/
CF8wUr5G6+5U9goKnDNjokKURRY1fY4rn4nYe+9ZBXohpzW5w7EXg12OYDBzrr7g
+j92jgl+1Bj0vVNB8o9CSA+R8jxEcVuXULkYBEQTSbm2PChIMQw=
=Cprp
-----END PGP SIGNATURE-----
--=-=-=--

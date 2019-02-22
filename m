Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8007C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 00:58:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E20D2080F
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 00:58:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726183AbfBVA6n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 19:58:43 -0500
Received: from mx2.suse.de ([195.135.220.15]:59530 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726178AbfBVA6m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 19:58:42 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id CC030AD12
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 00:58:41 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     linux-nfs <linux-nfs@vger.kernel.org>
Date:   Fri, 22 Feb 2019 11:58:34 +1100
Subject: Another OPEN / OPEN_DOWNGRADE race
Message-ID: <874l8wwsed.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain


Hi,
 I have a report of an NFSv4.1 state management problem in our 4.4
 kernel which appears to be caused by a race between OPEN and
 OPEN_DOWNGRADE, and I don't think the race is fixed in mainline.

 The test program creates multiple threads which open a file O_RDWR and
 write to it, then opens for O_RDONLY and reads from it.
 A network trace which shows the problem suggests that at a point in
 time where there are some O_RDONLY opens and one O_RDWR open, a new
 O_RDWR open is requested just as the O_RDWR open is being closed.

 The close of the O_RDWR clears state->n_rdwr early so can_open_cached()
 fails for the O_RDWR open, and it needs to go to the server.
 The open for O_RDWR doesn't increment n_rdwr until after the open
 succeeds, so nfs4_close_prepare sees
    n_rdwr == 0
    n_rdonly > 0
    NFS_O_RDWR_STATE and NFS_O_RDONLY_STATE set
 which causes it to choose an OPEN_DOWNGRADE.

 What we see is a OPEN/share-all and an OPEN_DOWNGRADE/share-read
 request are sent one after the other without waiting for a reply.
 The OPEN is processed first, then the OPEN_DOWNGRADE, resulting in a
 state that only allows reads.  Then a WRITE is attempted which fails.
 This enters a infinite loop with 2 steps:
  - a WRITE gets NFS4ERR_OPENMODE
  - a TEST_STATEID succeeds

 Once an OPEN/share-all request has been sent, it isn't really correct
 to send an OPEN_DOWNGRADE/share-read request.  However the fact that
 the OPEN has been sent isn't visible to nfs4_close_prepare().

 There is an asymmetry between open and close w.r.t. updating the
 n_[mode] counter and setting the NFS_O_mode_STATE bits.

 For close, the counter is decremented, then the server is told, then
 the state bits are cleared.
 For open, the counter and state bits are both cleared after the server
 is asked.

 I understand that this is probably because the OPEN could fail, and
 incrementing a counter before we are sure of success seems unwise.  But
 doing so would allow us to avoid the incorrect OPEN_DOWNGRADE.

 Any suggestions on what a good solution would look like?  Does it ever
 make sense for an OPEN request to be concurrent with a CLOSE or
 OPEN_DOWNGRADE ??  Maybe they should be serialized with each other
 (maybe not as fully serialized as NFSv4.0, but more than they currently
 are in NFSv4.1)

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlxvSTsACgkQOeye3VZi
gbkYcRAAl1LBv4cPVMFXJRRLz/D0VrpCzPQkPuISLPLdXzIpfOqpAyZYfJ1ipU/u
iulMiwMwSrBCaGZ36+Ufg4bhH1l2IVIITepMCJrDIB4CsJpVJ1t+C2+ZJcdNyyld
Tb1hsEZIwJ8lmdSjs1UGEHNWZNgmGl8WIL4G0F1ojtp7lACXzPGK+wmEEdXlq1l1
vQ4RhFxd09AlfsBv3g9FESgeC0u+HHexzGRc/P9WwTF8V2yF9EpP37foRbuPufPj
6jd/Tk1MqiQl3beESFB3q2E2VymcZu01EEm0hcEWrbw/twBnks8rnexLeeGl1dD8
40PCb6+2Uocxg8yZNzjRBJiMEmv2hi3IGi+UJfoXHKMJ51+Q0DI3smDgA72jV+vD
6NHtHvRVNL5+5VCZ+uo5llOUtSiYfhf6wnvdpwBS9dgEmY47Wct/0YXmHKSDw1b2
9Yryyoh1q4xPKeFWF15c7+KDSuzHLFm144f+V0WtZMqsNAsbup/vcVC4/dcBW0DO
9sM2S3ULhdfhCwbTG4P9cnHNVIfmRHszHdfk6v2u96WapsUf3Y5bP9sML6foXlDk
IFhZHlsvABL2tuzxiGZdAPbbK9uxmeYmLc1XLNMwecU3FKYQg7Bu7qUWQaw2V2nh
pYhmu93mWEH0OTnu/AMji9BoKoQqYv2X4EmuuOpu3ROTtWOn18A=
=vzvB
-----END PGP SIGNATURE-----
--=-=-=--

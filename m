Return-Path: <SRS0=UO7P=6A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6FA2C2BA19
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 00:30:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BAAF2206D6
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 00:30:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391781AbgDPAaA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Apr 2020 20:30:00 -0400
Received: from mx2.suse.de ([195.135.220.15]:42916 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2391755AbgDPA36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Apr 2020 20:29:58 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 39771AF8A;
        Thu, 16 Apr 2020 00:29:53 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "Anna.Schumaker\@Netapp.com" <Anna.Schumaker@Netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>
Date:   Thu, 16 Apr 2020 10:29:45 +1000
Cc:     linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Writeback fixes for NFS - V3
In-Reply-To: <87ftdgw58w.fsf@notabene.neil.brown.name>
References: <87tv2b7q72.fsf@notabene.neil.brown.name> <87v9miydai.fsf@notabene.neil.brown.name> <87ftdgw58w.fsf@notabene.neil.brown.name>
Message-ID: <87wo6gs26e.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain


This is version 3 (I think) of my patches to improve NFS writeaback.

Changes:
 - the code for adding legacy values to /proc/vmstat was broken.
   I haven't taken the approach that Michal and Jan discussed but
   a simpler (I hope) approach that just seq_puts() the lines at an
   appropriate place.

 - I've modified the handling of PF_LOCAL_THROTTLE - sufficiently that
   I dropped Jan's reviewed-by.
   Rather than invoking the same behaviour as BDI_CAP_STRICTLIMIT,
   I now just use the part I needed.
   So if the global threshold is not exceeded, PF_LOCAL_THROTTLE tasks
   are not throttled.  This is the case for normal processes, but not
   when BDI_CAP_STRICTLIMIT is in effect.
   If the global threshold *is* exceeded, only then to we check the
   local per-bdi threshold.  If that is not exceeded then
   PF_LOCAL_THROTTLE again avoid any throttling.  Only if both the
   thresholds are exceeded are these tasks throttled.
   I think this is more refletive if what we actually need.


Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAl6XpvkACgkQOeye3VZi
gbmE0g//fohyxqVmWfY0gBY1Eu5eE69mCobqspLO+gxINBuecBNhzJRXDub+b9Jk
gGwg5NnJ0yJfUxN//Et4UzX+ZhQWg5rrJ9fYPXkNt4LrsRR1fnr31jUI3+S+XpcZ
GxnJjWCHskHVlqf7N9cjdFj+i6Yl4/yVqP0XqWtBVW+IDBvP8WAmICh5BM5rEqrB
0MEKRU3UwVFWLvn+tH6BrSboiSCNHIxsGL/t2nYQf3/CD+s00t4YzRp1FPzV8/WE
T1i93OdjiOzaWqDQs3VBaPqyb7fzo/Y35s/2cDJ/WXD2kuEDefmM5P+7uF/UUXir
DlCa1IC5mlbsP2qMsrJl4SgbL0IUgqZXpZZUU7n77N7hd6QznJMI60mXKBthrnwq
J6Tuua66nAWI7te6EHJkLYP5zTHiAa8dQEk5o7S0ENx/ojcoXjU2LWfMEgCVGrud
GUCHWWswFD4w3Xz29UDwAfUTkntbML77hgwlhUI9bKsOtu3IvlQ3npbyVS3DN8wu
WQh0YR5e/C3vAQA6vHgw3WhJcMG2vqqMdZeCIwcGOBZ9Z+c00j7t+T9PN2UHiLWs
3OX6yo70TJwYvzRqWrqWJMnaQ1kPxMJVDCt9ZteVkCgmE/PTYCqDNuAUKnZds5Ej
XFbpwoyhzN/hxLJRbUOndIb7NJspO5hPVzJvkrrt9era8tXt7j8=
=pJOU
-----END PGP SIGNATURE-----
--=-=-=--

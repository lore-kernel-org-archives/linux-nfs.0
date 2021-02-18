Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D231C433DB
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Feb 2021 04:05:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DFD7B64DEC
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Feb 2021 04:05:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230128AbhBREFL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Feb 2021 23:05:11 -0500
Received: from mx2.suse.de ([195.135.220.15]:37738 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230122AbhBREFK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Feb 2021 23:05:10 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 7CF55AC6E;
        Thu, 18 Feb 2021 04:04:29 +0000 (UTC)
From:   NeilBrown <neil@brown.name>
To:     Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date:   Thu, 18 Feb 2021 15:04:25 +1100
Subject: Re: [PATCH 1/1] nfs-utiles: rename xlog_from_conffile() to
 xlog_set_debug()
In-Reply-To: <20210217201836.95788-1-steved@redhat.com>
References: <20210217201836.95788-1-steved@redhat.com>
Message-ID: <87v9aqhvhy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain

On Wed, Feb 17 2021, Steve Dickson wrote:

> Standardized how config setting are set as
> well as the rename
>
> Signed-off-by: Steve Dickson <steved@redhat.com>

Looks good to me - thanks.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJEBAEBCAAuFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAmAt50kQHG5laWxAYnJv
d24ubmFtZQAKCRA57J7dVmKBub6+EACzN2fSp3HDz54gjwKVp5eVZbTvDFv4QAve
CyWOxpc3E2NtDAjjG00sczs+ajtLxjX6rhGUsuD0SQrd/UgzWNS4SqRAKTsOM5Fi
HOuiW6EVoB6BRAGdNClb/yl8B+yhV8txqvMKoSL2YNB7YQaoMwfI/c0vZXrgM7Qo
N4iIdNmTVgMmYcLWuBE0UwxxYBQMz89KMeZBYou4c0hVHir1ce69f41TTGxVIFr1
qxNGhSpiaHWyLMf4VMwNCt/d3QrBGbz9V50yTALZRZueVByOgUWT1va3Rd2M56c5
AJbR+90b4W4xMMcEi2YXlRB6xT/Q7koASru0xfhIQUdNM0dddwcC+lPc7W5FsdNF
/ZFcFbIgX+HTeAFW54ppqQkBJwpGjqto+Buz9jeCtaSruJp2u92GOYR2T/q3hkus
KqKToEPDy9YoKizBTm3jnwUE0Vud7C4gtwC2N0QILIiqujJhHOB9MJfsy+xxVVCg
d7pzUoARWEGObxluVELIJeeQ0rMAD/sG75MW5brIdkVw81kktx3eCRpefPJfML3d
Ya64rYLIA5hqw/4yybsjBz9pl4wZb/Z72bmZuPcjmRDAIl7uJ2NR+HCmkz8ztHqN
vvh2qgGgROMB+hSyYN7JTKl4Q3fIdrlK8Pbx55dPS9PpcvuX9oHD0cyIYNGoVMRx
WSwC24JS5A==
=ZQaW
-----END PGP SIGNATURE-----
--=-=-=--

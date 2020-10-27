Return-Path: <SRS0=QBgL=EC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6784C55178
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Oct 2020 17:49:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 056C722456
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Oct 2020 17:49:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="LZvYij7K"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1822055AbgJ0Rtu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Oct 2020 13:49:50 -0400
Received: from fieldses.org ([173.255.197.46]:45442 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1822382AbgJ0Rtp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Oct 2020 13:49:45 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 2A69DABC; Tue, 27 Oct 2020 13:49:45 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 2A69DABC
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1603820985;
        bh=nLBK5Lq+nrEzSHDinscrMmcbNRYy4GQiBUKhmXrqJBc=;
        h=Date:To:Cc:Subject:From:From;
        b=LZvYij7KOlTn2d8pVKYhrWnSd/VFpj/cHO6PS+uT7hp5T21vkHL6paz9dUEXz0s8c
         nSbnUX9On9oJeTrq/Zl28703/+PLl6Tr3JJGOU1xvsoai2VYqJhRk/Fo2tyGSxKT1R
         6RVDu/VneIoJOFxpJ5Plj9aZuQY3wn/SdPRMTfBo=
Date:   Tue, 27 Oct 2020 13:49:45 -0400
To:     Anna Schumaker <schumakeranna@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: xfstests generic/263
Message-ID: <20201027174945.GC1644@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Generic/263 is failing whenever client and server both supports
READ_PLUS.

I'm not even sure the failure is wrong.  The NFS FALLOC operation doesn't
support those other other fallocate modes, are they implemented elsewhere in
the kernel or libc somehow?  Anyway, odd that it would have anything to do with
READ_PLUS.

--b.

generic/263 109s ... [failed, exit status 1]- output mismatch (see /root/xfstests-dev/results//generic/263.out.bad)
    --- tests/generic/263.out	2019-12-20 17:34:10.493343575 -0500
    +++ /root/xfstests-dev/results//generic/263.out.bad	2020-10-27 13:43:41.968835322 -0400
    @@ -1,3 +1,2018 @@
     QA output created by 263
     fsx -N 10000 -o 8192 -l 500000 -r PSIZE -t BSIZE -w BSIZE -Z
    -fsx -N 10000 -o 128000 -l 500000 -r PSIZE -t BSIZE -w BSIZE -Z
    +Seed set to 1
    +main: filesystem does not support fallocate mode FALLOC_FL_KEEP_SIZE, disabling!
    +main: filesystem does not support fallocate mode FALLOC_FL_ZERO_RANGE, disabling!
    +main: filesystem does not support fallocate mode FALLOC_FL_COLLAPSE_RANGE, disabling!
    ...
    (Run 'diff -u /root/xfstests-dev/tests/generic/263.out /root/xfstests-dev/results//generic/263.out.bad'  to see the entire diff)
Ran: generic/263
Failures: generic/263
Failed 1 of 1 tests

Return-Path: <SRS0=Jjwl=XS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AB96C4CECF
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 20:00:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4A68F20820
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 20:00:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387525AbfIWUAg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Sep 2019 16:00:36 -0400
Received: from fieldses.org ([173.255.197.46]:57986 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726777AbfIWUAg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Sep 2019 16:00:36 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 463A2150D; Mon, 23 Sep 2019 16:00:36 -0400 (EDT)
Date:   Mon, 23 Sep 2019 16:00:36 -0400
To:     fstests@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: generic/495: swap on sparse file over NFS
Message-ID: <20190923200036.GA5085@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'm updating to a newer xfstests and seeing:

generic/495     - output mismatch (see
/root/xfstests-dev/results//generic/495.out.bad)
    --- tests/generic/495.out   2019-09-18 17:28:00.834721480 -0400
    +++ /root/xfstests-dev/results//generic/495.out.bad 2019-09-20 13:34:01.1568
89741 -0400
    @@ -1,5 +1,4 @@
     QA output created by 495
     File with holes
    -swapon: Invalid argument
     Empty swap file (only swap header)
     swapon: Invalid argument

If I understand correctly, it's requiring swapon to fail on a sparse
file, which isn't going to happen on NFS, where the sparsenes of the
file isn't really the client's concern.

Is it really correct to *require* swapon to fail in this case?

--b.

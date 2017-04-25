Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:54454 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1428904AbdDYJuS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Apr 2017 05:50:18 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 5F519280381
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:16 +0200 (CEST)
Received: from spamfilter3.desy.de (spamfilter3.desy.de [131.169.56.144])
        by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 5425C11C9
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:16 +0200 (MEST)
Received: from spamfilter3.desy.de (localhost [127.0.0.1])
        by localhost.domain.tld (DESY MTA) with ESMTP id 13FF218E78C
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:15 +0200 (CEST)
Received: from amavis03.desy.de (lb-56-26.desy.de [131.169.56.26])
        by spamfilter3.desy.de (DESY MTA) with ESMTP id 1277918E778
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:15 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
        by amavis03.desy.de (Postfix) with ESMTP id 08A5D7F46F
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:15 +0200 (CEST)
Received: from amavis03.desy.de ([127.0.0.1])
        by localhost (amavis03.desy.de [127.0.0.1]) (amavisd-new, port 10027)
        with ESMTP id A2nnztC_vzgV for <linux-nfs@vger.kernel.org>;
        Tue, 25 Apr 2017 11:50:14 +0200 (CEST)
Received: from smtp-intra-1.desy.de (lb-56-26.desy.de [131.169.56.26])
        by amavis03.desy.de (Postfix) with ESMTP id E5C0A7F452
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:14 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id DD5A33E901
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 11:50:14 +0200 (MEST)
Date: Tue, 25 Apr 2017 11:50:14 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1888681645.2589111.1493113814857.JavaMail.zimbra@desy.de>
Subject: nfstop - top like utility for nfs traffic
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi all,

By investigating some clients misbehave, I have build a small tool,
that allows to display nfs traffic on top-like fashion. As a bonus,
when running on client host with modern kernels, it can match network
packets to PIDs by matching XIDs taken from kernel traces.

Maybe someone else will need it as well:

https://github.com/kofemann/nfstop

Tigran.

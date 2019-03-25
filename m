Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 085C1C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 05:14:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D22E3205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 05:14:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726260AbfCYFOK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 01:14:10 -0400
Received: from mfb02-md.ns.itscom.net ([175.177.155.110]:50835 "EHLO
        mfb02-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726241AbfCYFOK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2019 01:14:10 -0400
X-Greylist: delayed 329 seconds by postgrey-1.27 at vger.kernel.org; Mon, 25 Mar 2019 01:14:09 EDT
Received: from mail04-md.ns.itscom.net (mail04-md.ns.itscom.net [175.177.155.114])
        by mfb02-md.ns.itscom.net (Postfix) with ESMTP id A4489174812D
        for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2019 14:08:40 +0900 (JST)
Received: from scan20-mds.s.noc.itscom.net (scan20-md.ns.itscom.net [175.177.155.57])
        by mail04-md-outgoing.ns.itscom.net (Postfix) with ESMTP id 28B2D6205B4;
        Mon, 25 Mar 2019 14:08:39 +0900 (JST)
Received: from unknown (HELO mail02-md-outgoing.ns.itscom.net) ([175.177.155.112])
  by scan20-mds.s.noc.itscom.net with ESMTP; 25 Mar 2019 14:08:39 +0900
Received: from jromail.nowhere (h219-110-246-072.catv02.itscom.jp [219.110.246.72])
        by mail02-md-outgoing.ns.itscom.net (Postfix) with ESMTP;
        Mon, 25 Mar 2019 14:08:38 +0900 (JST)
Received: from jro by jrobl id 1h8Hqg-0006mD-RI ; Mon, 25 Mar 2019 14:08:38 +0900
From:   "J. R. Okajima" <hooanon05g@gmail.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: nfs4 v5.1-rc1, listxattr succeeded but getxattr
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <26051.1553490518.1@jrobl>
Date:   Mon, 25 Mar 2019 14:08:38 +0900
Message-ID: <26052.1553490518@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On linux-v5.1-rc1, NFSv4 listxattr(2) returns "system.nfs4_acl".  It is
OK, but getxattr(2) returns EOPNOTSUPP.  Is it an expected behaviour?

On v5.0, NFSv4 getxattr(2) didn't return the error.


J. R. Okajima

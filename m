Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1E80C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:15:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7AB5521736
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:15:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727091AbfBSXP4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:15:56 -0500
Received: from mails2n0-route0.email.arizona.edu ([128.196.130.122]:49541 "EHLO
        mails2n0-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726405AbfBSXP4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 18:15:56 -0500
X-Greylist: delayed 707 seconds by postgrey-1.27 at vger.kernel.org; Tue, 19 Feb 2019 18:15:56 EST
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A2DtAAD+imxc/+CVxIBkHAEBAQQBAQc?=
 =?us-ascii?q?EAQGBUwUBAQsBg1sShC2IeYtfAQEBBoEICJJXhWmBewEMExgBgUuCdQKEDTY?=
 =?us-ascii?q?HDQEDAQEBAQEBAm2FcwYjFVEIAw0NAiYCAleDOYFmDa1PgS8ahSqDAR4HgUu?=
 =?us-ascii?q?BC4tQeIEHgTgMgl+FToI8glcCgSmGP4ktO5F4CYJfBEmPJwYZgWEBgV6HMwO?=
 =?us-ascii?q?IDpxqgU4ELYFWTSUTgVmBT4InF44+H4E1CAEVCBIBCgGMHAEB?=
X-IPAS-Result: =?us-ascii?q?A2DtAAD+imxc/+CVxIBkHAEBAQQBAQcEAQGBUwUBAQsBg?=
 =?us-ascii?q?1sShC2IeYtfAQEBBoEICJJXhWmBewEMExgBgUuCdQKEDTYHDQEDAQEBAQEBA?=
 =?us-ascii?q?m2FcwYjFVEIAw0NAiYCAleDOYFmDa1PgS8ahSqDAR4HgUuBC4tQeIEHgTgMg?=
 =?us-ascii?q?l+FToI8glcCgSmGP4ktO5F4CYJfBEmPJwYZgWEBgV6HMwOIDpxqgU4ELYFWT?=
 =?us-ascii?q?SUTgVmBT4InF44+H4E1CAEVCBIBCgGMHAEB?=
X-IronPort-AV: E=Sophos;i="5.58,388,1544511600"; 
   d="scan'208";a="359263889"
Received: from unknown (HELO [128.196.149.224]) ([128.196.149.224])
  by mails2n0out.email.arizona.edu with ESMTP/TLS/AES128-SHA; 19 Feb 2019 16:03:52 -0700
Subject: Re: echo rdma 20049 > /proc/fs/nfsd/portlist return Protocol not
 supported
To:     linux-nfs@vger.kernel.org
References: <CAP9+kVAfSwkOAswGN3_OP6S3iaDoDq2HVq=wZccojMcq7hDC4g@mail.gmail.com>
From:   Chandler <admin@genome.arizona.edu>
Message-ID: <8d44b7c1-2423-adb3-2075-168e9abeaab1@genome.arizona.edu>
Date:   Tue, 19 Feb 2019 16:03:51 -0700
MIME-Version: 1.0
In-Reply-To: <CAP9+kVAfSwkOAswGN3_OP6S3iaDoDq2HVq=wZccojMcq7hDC4g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Mellanox did remove NFS RDMA support from their software a while ago, so 
that is why you see the error.  As far as I know, the only way to make 
it work is to remove the MLNX_OFED software and use CentOS Infiniband 
drivers.  Although we did have system freezes in CentOS 6.9 with NFS 
RDMA and so had to revert to the IPoIB interface.  Hopefully you'll have 
better luck with CentOS 7.

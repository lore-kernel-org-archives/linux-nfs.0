Return-Path: <SRS0=cvff=7E=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 948C3C433E0
	for <linux-nfs@archiver.kernel.org>; Fri, 22 May 2020 02:03:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 67CB12072C
	for <linux-nfs@archiver.kernel.org>; Fri, 22 May 2020 02:03:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726973AbgEVCDb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 May 2020 22:03:31 -0400
Received: from mx2.suse.de ([195.135.220.15]:47076 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726335AbgEVCDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 May 2020 22:03:30 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id DC69FB007;
        Fri, 22 May 2020 02:03:31 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, kircherlike@outlook.com,
        Stephen Hemminger <stephen@networkplumber.org>
Date:   Fri, 22 May 2020 12:01:32 +1000
Subject: [PATCH 0/3 - V2] SUNRPC/svc: fix gss flavour registration problems.
Cc:     linux-nfs@vger.kernel.org
Message-ID: <159011265914.29107.13764997801950546826.stgit@noble>
User-Agent: StGit/0.21
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In this second version:
 - #include added in first patch so new function is declare both where 
   it is defined and where it is used
 - doxy comment added for auth_domain_cleanup()
 - pr_warn() used instead of printk
 - 'svc:' used as message prefix
 - EADDRINUSE returned instead of EALREADY - I think it is slightly more
   accurate.
 - 'cc: stable' dropped for first patch.  Bug goes back before 'git' so
   no 'Fixes:'
 - minor code revision

Thanks,
NeilBrown
---

NeilBrown (3):
      sunrpc: check that domain table is empty at module unload.
      sunrpc: svcauth_gss_register_pseudoflavor must reject duplicate registrations.
      sunrpc: clean up properly in gss_mech_unregister()


 include/linux/sunrpc/gss_api.h        |    1 +
 include/linux/sunrpc/svcauth_gss.h    |    3 ++-
 net/sunrpc/auth_gss/gss_mech_switch.c |   12 +++++++++---
 net/sunrpc/auth_gss/svcauth_gss.c     |   18 ++++++++++--------
 net/sunrpc/sunrpc.h                   |    1 +
 net/sunrpc/sunrpc_syms.c              |    2 ++
 net/sunrpc/svcauth.c                  |   25 +++++++++++++++++++++++++
 7 files changed, 50 insertions(+), 12 deletions(-)

--
Signature


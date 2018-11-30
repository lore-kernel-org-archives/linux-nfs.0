Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B10BC65BAE
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 17:41:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0630120867
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 17:41:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0630120867
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726650AbeLAEvx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 23:51:53 -0500
Received: from mx1.redhat.com ([209.132.183.28]:48703 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727040AbeLAEvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 23:51:53 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DE8B4307C717;
        Fri, 30 Nov 2018 17:41:51 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-120-28.rdu2.redhat.com [10.10.120.28])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 91B3B61F2C;
        Fri, 30 Nov 2018 17:41:51 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 184F72078D; Fri, 30 Nov 2018 12:41:51 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/1] NFSv4: deal with v4.0 servers that request confirmation on reclaim-type opens
Date:   Fri, 30 Nov 2018 12:41:50 -0500
Message-Id: <20181130174151.19448-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 30 Nov 2018 17:41:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A Red Hat customer started having problems with open reclaims after a
kernel upgrade.  It turns out that the customer's NFS server is setting
the OPEN4_RESULT_CONFIRM in response to an OPEN(CLAIM_PREVIOUS), which
is not permitted by RFC 7530.

The client used to be able to handle that because nfs4_open_prepare() used
to copy the filehandle from the OPEN args to the OPEN results when doing
an open by filehandle.  That copy was removed by commit 4e2fcac77390
"nfsv4: Use correct inode in _nfs4_opendata_to_nfs4_state()".

It looks to me like adding the copy back in would not affect the
behavior of the nfs4_opendata_get_inode() helper that was added in
4e2fcac77390 (it uses the filehandle to look up the inode when doing an
open by name)... so this patch adds the copy back in and also adds a
warning in the event that the client does receive OPEN4_RESULT_CONFIRM
in response to an OPEN(CLAIM_PREVIOUS).

Scott Mayhew (1):
  NFSv4: deal with v4.0 servers that request confirmation on
    reclaim-type opens

 fs/nfs/nfs4proc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

-- 
2.17.1


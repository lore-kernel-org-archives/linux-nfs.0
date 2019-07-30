Return-Path: <SRS0=Ztr/=V3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C21D1C32750
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Jul 2019 21:10:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9CFB12067D
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Jul 2019 21:10:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726050AbfG3VJ7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Jul 2019 17:09:59 -0400
Received: from mx1.redhat.com ([209.132.183.28]:46110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728214AbfG3VJ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Jul 2019 17:09:56 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 54E183082138
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jul 2019 21:09:56 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-120-110.rdu2.redhat.com [10.10.120.110])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 374CA5D6A7;
        Tue, 30 Jul 2019 21:09:56 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id C9FC0208C3; Tue, 30 Jul 2019 17:09:50 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH RFC 0/2] add principal to the data being tracked by nfsdcld
Date:   Tue, 30 Jul 2019 17:09:48 -0400
Message-Id: <20190730210950.10545-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 30 Jul 2019 21:09:56 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

At the spring bakeathon, Chuck suggested that we should store the
kerberos principal in addition to the client id string in nfsdcld.  The
idea is to prevent an illegitimate client from reclaiming another
client's opens by supplying that client's id string.  This is an initial
attempt at doing that.

The first patch adds support for a "GetVersion" upcall which allows nfsd
to determine the maximum message version that nfsdcld supports.  Right
now it's based on the value of CLD_UPCALL_VERSION from cld.h, but I was
thinking we may wish to add a command-line option (and an nfs.conf)
option to make it possible to use a lower version than
CLD_UPCALL_VERSION.  My thinking here is that an older nfsdcld daemon
won't be compatible with the new database schema... rather than worrying
about messing with downgrading the database, just use the command-line
option to make it behave like an older daemon.

The second patch adds handling for the v2 Cld_Create and Cld_GraceStart
upcalls, which can include the kerberos principal which we'll store
along with the client id string in the database.  Note that if we're
talking to an old kernel that does the v1 upcall, everything still works
(we just ignore the new columns in the database).

Question: Why do we have a copy of cld.h in support/include?  It seems
unnecessary... maybe we should get rid of it so that we're always
using the cld.h from the kernel headers?

Scott Mayhew (2):
  nfsdcld: add a "GetVersion" upcall
  nfsdcld: add support for upcall version 2

 support/include/cld.h        |  37 +++++-
 utils/nfsdcld/cld-internal.h |  13 +-
 utils/nfsdcld/nfsdcld.c      | 140 +++++++++++++++++----
 utils/nfsdcld/sqlite.c       | 238 +++++++++++++++++++++++++++++------
 utils/nfsdcld/sqlite.h       |   2 +
 5 files changed, 366 insertions(+), 64 deletions(-)

-- 
2.17.2


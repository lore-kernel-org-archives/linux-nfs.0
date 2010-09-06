Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49180 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755200Ab0IFDfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Sep 2010 23:35:08 -0400
Message-ID: <4C846162.40305@cn.fujitsu.com>
Date: Mon, 06 Sep 2010 11:34:58 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2]gss:gss miss returning error to caller when import security
 context
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Gss miss returning error to caller when import security context, 
it may be return ok though it has failed to import security context.

Bian Naimeng (2)

----
 net/sunrpc/auth_gss/gss_krb5_mech.c  |   10 ++++++++--
 net/sunrpc/auth_gss/gss_spkm3_mech.c |    5 ++++-
 2 files changed, 12 insertions(+), 3 deletions(-)

-- 
Regards
Bian Naimeng


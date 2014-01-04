Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:46166 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbaADMSN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jan 2014 07:18:13 -0500
Received: by mail-qc0-f179.google.com with SMTP id i8so15587200qcq.38
        for <linux-nfs@vger.kernel.org>; Sat, 04 Jan 2014 04:18:12 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, ssorce@redhat.com, neilb@suse.de
Subject: [PATCH 0/3] sunrpc: change handling of use-gss-proxy file
Date: Sat,  4 Jan 2014 07:18:02 -0500
Message-Id: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset fixes a couple of problems with the use-gss-proxy procfile
and does some general cleanup around that code. Bruce, can you consider
this for 3.14? Getting it into linux-next soon would be good too...

Thanks,

Jeff Layton (3):
  sunrpc: don't wait for write before allowing reads from use-gss-proxy
    file
  sunrpc: fix potential race between setting use_gss_proxy and the
    upcall rpc_clnt
  sunrpc: get rid of use_gssp_lock

 net/sunrpc/auth_gss/gss_rpc_upcall.c |  2 -
 net/sunrpc/auth_gss/svcauth_gss.c    | 75 ++++++++++--------------------------
 net/sunrpc/netns.h                   |  1 -
 3 files changed, 20 insertions(+), 58 deletions(-)

-- 
1.8.4.2


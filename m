Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60656 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865Ab3EOTvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 15:51:12 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Speed up detection of whether or not rpc.gssd is running
Date: Wed, 15 May 2013 12:50:38 -0700
Message-Id: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also fix the auth_gss pipe version detection so that it works correctly
in the presence of namespaces.

Trond Myklebust (3):
  SUNRPC: Fix a bug in gss_create_upcall
  SUNRPC: Faster detection if gssd is actually running
  SUNRPC: Convert auth_gss pipe detection to work in namespaces

 net/sunrpc/auth_gss/auth_gss.c | 62 ++++++++++++++++++++++++++++--------------
 net/sunrpc/netns.h             |  4 +++
 net/sunrpc/rpc_pipe.c          |  5 ++++
 3 files changed, 50 insertions(+), 21 deletions(-)

-- 
1.8.1.4


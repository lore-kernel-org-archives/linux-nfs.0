Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:55352 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbcAFQvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2016 11:51:47 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id ACD512801B3
	for <linux-nfs@vger.kernel.org>; Wed,  6 Jan 2016 17:51:45 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 88E9113F49
	for <linux-nfs@vger.kernel.org>; Wed,  6 Jan 2016 17:51:45 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Question-patch 
Date: Wed,  6 Jan 2016 17:51:29 +0100
Message-Id: <1452099090-31729-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[PATCH] nfs: set RPC_TASK_TIMEOUT on rpc task to separate TIMEOUT

This is more or less a patch-question: will this break something and if not,
why we don't have it? Currently we always get EIO and cant really tell what it was

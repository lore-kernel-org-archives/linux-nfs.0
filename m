Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932658AbcLGWek (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 17:34:40 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "Trond Myklebust" <trondmy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Concurrent `ls` takes out the thrash
Date: Wed,  7 Dec 2016 17:34:39 -0500
Message-Id: <934FC075-4393-42AD-92A3-3BC3BE580699@redhat.com>
In-Reply-To: <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com> <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com> <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Benjamin Coddington" <bcodding@redhat.com>

So, I've got the following patch, and it seems to work fine for the original
workload.  However, if I use ~20 procs started 2 seconds apart, I can still
sometimes get into the state where the machine takes a very long time (5 - 8
minutes).  I wonder if I am getting into a state were vmscan is reclaiming
pages while I'm trying to fill them up.  So.. I'll do a bit more debugging
and re-post this if I feel like it is still the right approach.

Adding an int to nfs_open_dir_context puts it at 60 bytes here.  Probably
could have added a unsigned long flags and used bits for the duped stuff as
well, but it was uglier that way, so I left it.  I like how duped carries
-1, 0, and >1 information without having flag defines cluttering everywhere.

Ben

8<------------------------------------------------------------------------

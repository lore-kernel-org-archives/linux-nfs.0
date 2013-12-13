Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f182.google.com ([209.85.215.182]:41495 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab3LMKBa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2013 05:01:30 -0500
Received: by mail-ea0-f182.google.com with SMTP id a15so760137eae.27
        for <linux-nfs@vger.kernel.org>; Fri, 13 Dec 2013 02:01:28 -0800 (PST)
Message-ID: <52AADAF6.40700@primarydata.com>
Date: Fri, 13 Dec 2013 12:01:26 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: bfields@redhat.com
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] a couple fixes in nfsd4_release_lockowner
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, while working on the state mutex elimination stuff I saw these two issues
in nfsd4_release_lockowner.  These patches are untested but I just wanted to quickly get
your take on them.

[PATCH 1/2] nfsd4: break from inner lookup loop in nfsd4_release_lockowner on first match

looks like a potential list corruption risk.

[PATCH 2/2] nfsd4: ignore nfsv4.1 lockowners in nfsd4_release_lockowner

I'm not sure that 100% needed but since we keep both nfsv4.0 and v4.1 owners
hashed on the same lists we don't want a v4.0 operation to accidentally
touch v4.1 state.

Benny

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:51458 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161045AbcFOD2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2016 23:28:23 -0400
From: Oleg Drokin <green@linuxhacker.ru>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH 0/3] nfsd state handling fixes
Date: Tue, 14 Jun 2016 23:28:03 -0400
Message-Id: <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1465945026.12291.5.camel@poochiereds.net>
References: <1465945026.12291.5.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These three patches do the much discussed job of making nfsd state handling
more robust in face of races where several opens arrive for the same file
at the same time from the same client.

This does not yet handle a case when one of those opens gets an error
and others don't.

Also this is undergoing testing ATM, so please only use it as a
discussion/review piece for now.

Oleg Drokin (3):
  nfsd: Always lock state exclusively.
  nfsd: Extend the mutex holding region around in nfsd4_process_open2()
  nfsd: Make init_open_stateid() a bit more whole

 fs/nfsd/nfs4state.c | 67 +++++++++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 38 insertions(+), 31 deletions(-)

-- 
2.7.4


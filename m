Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:39487 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521AbbFPKI6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2015 06:08:58 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 9B4A5280373
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 12:08:56 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 8C87E1183
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 12:08:56 +0200 (MEST)
Date: Tue, 16 Jun 2015 12:08:55 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1857695394.3971135.1434449335470.JavaMail.zimbra@desy.de>
Subject: crash on read overflow
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Trond,

with RHEL6 kernel we observe kernel panic if server reply
more data than client requested. This is obviously fixed in
RHEL7 and upstream. Unfortunately, kernel crashes so badly
that I can't get any stacktrace. My guess is that
commit 64bd577ea0021f5903505de061b3b7d8a785ee94 is the one
which fixes the issue. Can you confirm?

Tigran.


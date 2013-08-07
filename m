Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:39677 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932587Ab3HGUi5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 16:38:57 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 18AC1280438
	for <linux-nfs@vger.kernel.org>; Wed,  7 Aug 2013 22:30:28 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id E475713EA4
	for <linux-nfs@vger.kernel.org>; Wed,  7 Aug 2013 22:30:27 +0200 (MEST)
Date: Wed, 7 Aug 2013 22:30:27 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Weston Andros Adamson <dros@netapp.com>
Message-ID: <1755011550.291762.1375907427574.JavaMail.zimbra@desy.de>
In-Reply-To: <1801820012.291748.1375907221530.JavaMail.zimbra@desy.de>
Subject: weird moutstats with pnfs
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi, 

I am running some IO tests with pNFS and see some strange(at least to me) numbers:

WRITE:
	44316 ops (249%) 	0 retrans (0%) 	0 major timeouts
	avg bytes sent per op: 179112	avg bytes received per op: 111
	backlog wait: 2416.041204 	RTT: 11.033735 	total execute time: 2427.148953 (milliseconds)


249% What does it tell me?

This is fedora19 with 3.10.3-300.fc19.x86_64 kernel.

Tigran.

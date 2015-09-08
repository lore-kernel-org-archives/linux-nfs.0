Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:34126 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193AbbIHNIi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2015 09:08:38 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 6537428090B
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2015 15:08:34 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 58AC213E95
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2015 15:08:33 +0200 (MEST)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP4.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tbcb9e919e683a96162fcc@ZITSWEEP4.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Tue, 8 Sep 2015 15:08:33 +0200
Received: from z-mta-2.desy.de (z-mta-2.desy.de [131.169.55.136])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id C24C53E902
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2015 15:08:32 +0200 (MEST)
Received: from z-mta-2.desy.de (localhost [127.0.0.1])
	by z-mta-2.desy.de (Postfix) with ESMTPS id BB84E2603C8
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2015 15:08:32 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by z-mta-2.desy.de (Postfix) with ESMTP id ADB082603C9
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2015 15:08:32 +0200 (CEST)
Received: from z-mta-2.desy.de ([127.0.0.1])
	by localhost (z-mta-2.desy.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id mMNuKyVWyL-G for <linux-nfs@vger.kernel.org>;
	Tue,  8 Sep 2015 15:08:32 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
	by z-mta-2.desy.de (Postfix) with ESMTP id 9A4112603C7
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2015 15:08:32 +0200 (CEST)
Date: Tue, 8 Sep 2015 15:08:32 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <267164181.6444770.1441717712553.JavaMail.zimbra@desy.de>
Subject: readdir and old cookie verifier
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dear NFS gurus,

we run into situation, where client gets BAD_COOKIE on a readdir.
Before I go and try to adopt our server to handle it, let me describe
the situation.

A client node (we have seen it with RHEL6 and Ubuntu 12.04, but probably
others affected as well) send a bunch of readdirs to the server. After some
time (this many be hours, days ) client sends an other set of readdirs. But
it reuses cookie verifier from the first readdir sequence. Server sends back
BAD_COOKIE, but client never starts over with a cookie and verifier being zero.
As a result, inconsistent listing and anhappy user:


[exflserv04] ~ $ ls /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/
ls: reading directory /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/: Unknown error 523

Is this behavior of the client correct?

Thanks a lot,
   Tigran.

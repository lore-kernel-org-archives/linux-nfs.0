Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33949 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163Ab2BOWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:45:22 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RxnbF-0004Kb-Pt
	for linux-nfs@vger.kernel.org; Wed, 15 Feb 2012 17:45:21 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: pynfs: cleanup and turn off some tests by default
Date: Wed, 15 Feb 2012 17:45:15 -0500
Message-Id: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've committed the following to my pynfs repo.

Fix a couple minor problems found while working on a bug, then turn off
utf8 and pnfs tests by default (both can still be requested by adding
"utf8" or "pnfs", respectively, on the commandline), and remove one
incorrect test.

I'd like to get to the point where the pynfs tests all pass against a
reasonable server.  That means fixing the server where necessary, of
course, but also not complaining about unimplemented optional features
or about stuff we don't plan to fix.

--b.


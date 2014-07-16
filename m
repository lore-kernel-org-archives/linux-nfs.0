Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48104 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbaGPTij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2014 15:38:39 -0400
Date: Wed, 16 Jul 2014 15:38:39 -0400
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: invalidating cache on chmod
Message-ID: <20140716193838.GD2397@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As of (a backport of) 3a1556e8662 "NFSv2/v3: Simulate the change
attribute" we have a user complaining about chmod on the client
invalidating data caches.  (They have some sort of pipeline running on
the client where output from one stage is has ownership and permissions,
but not data, change before being used as input to the next.)

Looks like that's expected?

--b.

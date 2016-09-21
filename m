Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36770 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758716AbcIUSDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 14:03:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [0/2] make nfsd's setclientid behavior migration-friendly 
Date: Wed, 21 Sep 2016 14:03:43 -0400
Message-Id: <1474481025-23702-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clients mounting multiple servers with the "migration" option may find
some mounts are made from the incorrect server.

I think this is really a bug in RFC 7931, and that RFC and the client
need fixing, but this is easy to mitigate on the server.  I'll make an
attempt at a client patch too.

--b.


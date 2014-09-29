Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752481AbaI2SWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 14:22:07 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8TIM7JP023363
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2014 14:22:07 -0400
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/1] Simplify rpcsec gss dependencies in unit files
Date: Mon, 29 Sep 2014 14:22:02 -0400
Message-Id: <1412014923-26587-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

*** BLURB HERE ***
Concentrate dependencies for rpcsec GSS stuff in one place.

Simo Sorce (1):
  Move the wants only to the auth unit.

 systemd/auth-rpcgss-module.service | 3 ++-
 systemd/nfs-client.target          | 4 ++--
 systemd/nfs-server.service         | 1 -
 3 files changed, 4 insertions(+), 4 deletions(-)

-- 
2.1.0


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbaAQQ4p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 11:56:45 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0HGuiYF007156
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jan 2014 11:56:44 -0500
From: Simo Sorce <simo@redhat.com>
To: jlayton@redhat.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Fix credential sourcing with new setuid behavior in rpc.gssd
Date: Fri, 17 Jan 2014 11:56:38 -0500
Message-Id: <1389977800-10922-1-git-send-email-simo@redhat.com>
In-Reply-To: <1389931919-4801-1-git-send-email-simo@redhat.com>
References: <1389931919-4801-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Take 3

Patch 1:
 - simply remove the old code that is not necessary anymore
 * removed an additional unused variable in take 3

Bonus patch 2:
 - clean up code, name is not needed anymore as the default
   credentials for the impersonated uid are always used.
 * also stopped passing uid needlessly around in take 3
   Pointed out by Steve, thanks.

Simo Sorce (2):
  Improve first attempt at acquiring GSS credentials
  Remove unused arguments

 utils/gssd/gssd_proc.c |    2 +-
 utils/gssd/krb5_util.c |   32 ++++++--------------------------
 utils/gssd/krb5_util.h |    2 +-
 3 files changed, 8 insertions(+), 28 deletions(-)


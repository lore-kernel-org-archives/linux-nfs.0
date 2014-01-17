Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbaAQEMF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jan 2014 23:12:05 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0H4C47C023427
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 23:12:05 -0500
From: Simo Sorce <simo@redhat.com>
To: jlayton@redhat.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Fix credential sourcing with new setuid behavior in rpc.gssd
Date: Thu, 16 Jan 2014 23:11:57 -0500
Message-Id: <1389931919-4801-1-git-send-email-simo@redhat.com>
In-Reply-To: <20140116204949.1bea663a@corrin.poochiereds.net>
References: <20140116204949.1bea663a@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Take 2

Patch 1: simply remove the old code that is not necessary anymore

Bonus patch 2: clean up code, name is not needed anymore as the default
credentials for the impersonated uid are always used.

Simo Sorce (2):
  Improve first attempt at acquiring GSS credentials
  Remove unused parameter

 utils/gssd/krb5_util.c |   28 ++++------------------------
 1 files changed, 4 insertions(+), 24 deletions(-)


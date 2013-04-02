Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761237Ab3DBTce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 15:32:34 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32JWXOK030850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 15:32:34 -0400
Received: from willson.li.ssimo.org.com (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r32JWXuo021784
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 15:32:33 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Alternative patchset to avoid PTR lookups
Date: Tue,  2 Apr 2013 15:32:27 -0400
Message-Id: <1364931149-18484-1-git-send-email-simo@redhat.com>
In-Reply-To: <515B2F8D.3030302@RedHat.com>
References: <515B2F8D.3030302@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This one does the same thing as the previous but uses -z/-Z options.

Pick the one you like most, but this one is less code, so I guess it is
porefereable.

Simo Sorce (2):
  Avoid reverse resolution for server name
  Document new -z/-Z options

 utils/gssd/gss_util.h  |    2 ++
 utils/gssd/gssd.c      |   10 ++++++++--
 utils/gssd/gssd.man    |   13 ++++++++++++-
 utils/gssd/gssd_proc.c |   25 +++++++++++++++++++++----
 4 files changed, 43 insertions(+), 7 deletions(-)


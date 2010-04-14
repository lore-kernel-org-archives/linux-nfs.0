Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:49709 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752983Ab0DNTSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 15:18:52 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O286r-0006m9-Tq
	for linux-nfs@vger.kernel.org; Wed, 14 Apr 2010 15:18:50 -0400
From: steved@redhat.com
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfs-utils: Adds support for more encryption types.
Date: Wed, 14 Apr 2010 15:18:46 -0400
Message-Id: <1271272729-24422-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Steve Dickson <steved@redhat.com>

These three gssd patches added support for more DES and non-DES
encryption types. They were authored by Kevin Coffman and tested
by me on several recent kernels. 

Kevin Coffman (3):
  gssd: move function limit_krb5_enctypes into the exported functions area
  Try to use kernel function to determine supported Kerberos enctypes.
  Add support for non-DES encryption types.


 utils/gssd/context.h       |    6 ++-
 utils/gssd/context_lucid.c |  128 ++++++++++++++++++++++++++++++++++++-----
 utils/gssd/context_mit.c   |  136 +++++++++++++++++++++++++++++++++-----------
 utils/gssd/gssd_proc.c     |   81 ++++++++++++++++++++++++++-
 utils/gssd/krb5_util.c     |  121 +++++++++++++++++++++------------------
 5 files changed, 368 insertions(+), 104 deletions(-)


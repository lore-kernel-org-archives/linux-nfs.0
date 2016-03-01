Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753690AbcCANRW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 08:17:22 -0500
Message-ID: <1456838234.2814.89.camel@redhat.com>
Subject: RPC_CRED_KEY_EXPIRE_SOON and RPC_CRED_NO_CRKEY_TIMEOUT
From: Harshula <harshula@redhat.com>
To: andros@netapp.com, "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 02 Mar 2016 00:17:14 +1100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy & Bruce,

re: Commit dc24826bfca8d788d05f625208f06d90be5560b3 (NFS avoid expired
credential keys for buffered writes)

Is it a valid state for ac_flags to have RPC_CRED_KEY_EXPIRE_SOON and
RPC_CRED_NO_CRKEY_TIMEOUT set at the same time?

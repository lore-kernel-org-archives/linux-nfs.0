From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] For 2.6.27: NFS mount option parsing fix-ups
Date: Thu, 12 Jun 2008 12:37:25 -0400
Message-ID: <20080612163416.13197.92911.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:65283 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbYFLQha (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 12:37:30 -0400
Received: by py-out-1112.google.com with SMTP id p76so1685277pyb.10
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 09:37:30 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

As a prelude to new features, here are some fixes and clean-ups for
various minor issues in the NFS client's mount option parser.

Please consider these for 2.6.27.

--
Chuck Lever
chu ckd otl eve rat ora cle dot com

From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Provide complete NFS mount option reporting
Date: Thu, 31 Jan 2008 15:00:11 -0500
Message-ID: <20080131195736.17975.43483.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: miklos@szeredi.hu, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:52863 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759107AbYAaUAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2008 15:00:33 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here's a slightly expanded, but tested, patch set (against 2.6.24) that adds
support for displaying several mount options to nfs_show_options.  This should
be enough to support Miklos' goals.  Please consider this for NFS_ALL.

-- 
corporate:    <chuck dot lever at oracle dot com>

From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] NFS/RPC metrics fix-ups for 2.6.27
Date: Fri, 06 Jun 2008 13:22:08 -0400
Message-ID: <20080606172037.14757.64893.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:52499 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbYFFRWM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2008 13:22:12 -0400
Received: by wx-out-0506.google.com with SMTP id h29so779359wxd.4
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2008 10:22:11 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here are two patches that address minor issues with NFS and RPC performance
metrics.  See the patch descriptions for details.  Please consider these
for 2.6.27.

-- 
corporate:    <chuck dot lever at oracle dot com>

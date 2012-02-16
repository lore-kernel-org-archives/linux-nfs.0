Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36900 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab2BPSrA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:47:00 -0500
Received: by eekc14 with SMTP id c14so1011342eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:46:58 -0800 (PST)
Message-ID: <4F3D4F1F.6080502@tonian.com>
Date: Thu, 16 Feb 2012 20:46:55 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] nfsd41: want delegation flags
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[PATCH 1/3] nfsd41: share_access_to_flags should consider only nfs4.x share_access flags
[PATCH 2/3] nfsd41: split out share_access want and signel flags while decoding
[PATCH 3/3] nfsd41: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg

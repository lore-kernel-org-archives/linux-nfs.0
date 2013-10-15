Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:54406 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab3JOG4U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Oct 2013 02:56:20 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so3355208wgh.29
        for <linux-nfs@vger.kernel.org>; Mon, 14 Oct 2013 23:56:19 -0700 (PDT)
Message-ID: <525CE711.1040107@primarydata.com>
Date: Tue, 15 Oct 2013 09:56:17 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] nfsd: cleanup nfs4_put_delegation
References: <525CE652.3070704@primarydata.com>
In-Reply-To: <525CE652.3070704@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[PATCH 1/2] nfsd: nfs4_open_delegation needs to remove_stid rather than unhash_stid
	bug fix

[PATCH 2/2] nfsd: remove_stid can be incorporated into nfs4_put_delegation
	cleanup



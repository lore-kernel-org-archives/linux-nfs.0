Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f52.google.com ([209.85.160.52]:51002 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab3CBVYP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Mar 2013 16:24:15 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so2393407pbc.39
        for <linux-nfs@vger.kernel.org>; Sat, 02 Mar 2013 13:24:15 -0800 (PST)
Date: Sat, 2 Mar 2013 13:24:11 -0800
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: status of idr_alloc() conversion in nfsd?
Message-ID: <20130302212411.GB3678@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Bruce.

As we're reaching -rc1, I'm preparing final conversions and
deprecation of the old idr interface.  It seems like nfsd still hasn't
been converted.  It it gonna happen soon?

Thanks.

-- 
tejun

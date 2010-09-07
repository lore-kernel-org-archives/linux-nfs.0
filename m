Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932138Ab0IGUDj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:39 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3c91027210
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:39 -0700 (PDT)
Message-ID: <4C869A9A.6010809@netapp.com>
Date: Tue, 07 Sep 2010 16:03:38 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/6] NFS: New readdir cache
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


This set of patches adds an array for storing the results of an NFS readdir.
Until now, XDR structures had been stored in a cache page without doing any
decoding.  We will now decode the result to store in the page.  This allows us
to cache more information on a single page and to vmap multiple pages together
for large readdirs.

[PATCH 1/6] NFS: add readdir cache array
[PATCH 2/6] NFS: use readdir cache array
[PATCH 3/6] NFS: remove old readdir code
[PATCH 4/6] NFS: re-add readdir plus
[PATCH 5/6] NFS: remove readdir plus limit
[PATCH 6/6] NFS: readdir with vmapped pages

-Bryan

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:56785 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122Ab3FYTKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 15:10:19 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 25 Jun 2013 15:10:18 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id EF198C9005C
	for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 15:10:14 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5PJAD5f313484
	for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 15:10:14 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5PJA9L2008832
	for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 13:10:09 -0600
Date: Tue, 25 Jun 2013 14:10:08 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: nfsd dropping requests after lazy umount
Message-ID: <20130625191008.GA20277@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I have found an issue with lazy/forced unmounts with nfsd. Let us say
/nfs is a mount point, and we are exporting /nfs/exp directory.

After mounting from a client, this export will have a cache entry
"svc_export" in the kernel. The exports pathname
d_path(svc_export->ex_path) correctly resolves to "/nfs/exp"

After the /nfs is lazy unmounted, the d_path(svc_export->ex_path)
resolves to "/exp" only.

Now, if the cache entry needs revalidation, you will see "/exp" in the
nfsd.export/channel file that never gets cleared as that cache entry
will be in a forever CACHE_PENDING state. We will also see
svc_export_parse() failing with -2 err as such a pathname doesn't exist
in the system any more.

I noticed that svc_export has two fields: ex_path and ex_pathname.  Is
it possible to make a string comparison of d_path(ex_path) and
ex_pathname? If so, we should be able to fail the upcall without making
the upcall if those two don't match.

Regards, Malahal.


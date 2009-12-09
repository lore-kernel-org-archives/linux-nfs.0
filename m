Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6236 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753406AbZLIKYt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:24:49 -0500
Message-ID: <4B1F7AF6.2080305@panasas.com>
Date: Wed, 09 Dec 2009 12:24:54 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        pNFS Mailing List <pnfs@linux-nfs.org>
Subject: [PATCH 0/9] fixes to Initial pnfsd file layout support v2, comments
 {3,4,5}/35
References: <4B1CCA52.8020900@panasas.com>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce,

The following SQUASHME patches address your review comments for:
[PATCH v2 03/35] pnfsd, pnfs: protocol level pnfs constants
[PATCH v2 04/35] pnfsd: return pnfs flags on exchange_id
[PATCH v2 05/35] pnfsd: don't set up back channel on create_session for ds

I'm also posting the respective patches to the rest of the
linux-pnfs tree:

pnfsd-files-next:
[PATCH 1/3] SQUASHME: pnfsd: unify enum pnfs_layout{return,recall}_type
[PATCH 2/3] SQUASHME: pnfsd: always set both MDS and DS exchangeid capability flags
[PATCH 3/3] SQUASHME: pnfsd: define a is_ds_only_session helper

pnfsd:
[PATCH 4/4] SQUASHME: pnfsd: use only RETURN_* constants

spnfs:
[PATCH 5/5] SQUASHME: spnfs: use only RETURN_* constants

spnfs-blocks
[PATCH 6/6] SQUASHME: spnfs-block: use only RETURN_* constants

pnfsd-exofs:
[PATCH 7/7] SQUASHME: pnfsd-exofs: use only pnfs_layoutreturn_type

pnfs:
[PATCH 8/9] SQUASHME: pnfs: use only pnfs_layoutreturn_type
[PATCH 9/9] SQUASHME: pnfs: filelayout: mask out server's MDS capability flag for DSs

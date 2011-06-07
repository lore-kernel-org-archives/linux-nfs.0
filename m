Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52989 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab1FGR1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:19 -0400
Date: Tue, 7 Jun 2011 13:27:17 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 12/88] pnfsblock: expose scsi interface
Message-ID: <1363fd163b64fafa016d970e4d07eecf30aad319.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 drivers/scsi/hosts.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/hosts.c b/drivers/scsi/hosts.c
index 4f7a582..7d91903 100644
--- a/drivers/scsi/hosts.c
+++ b/drivers/scsi/hosts.c
@@ -50,10 +50,11 @@ static void scsi_host_cls_release(struct device *dev)
 	put_device(&class_to_shost(dev)->shost_gendev);
 }
 
-static struct class shost_class = {
+struct class shost_class = {
 	.name		= "scsi_host",
 	.dev_release	= scsi_host_cls_release,
 };
+EXPORT_SYMBOL(shost_class);
 
 /**
  *	scsi_host_set_state - Take the given host through the host state model.
-- 
1.7.4.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:45056 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab1GNQuF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 12:50:05 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by merit-proxy01.merit.edu (Postfix) with ESMTP id 181B02039875
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 12:50:05 -0400 (EDT)
Received: from merit-proxy01.merit.edu ([127.0.0.1])
	by localhost (merit-proxy01.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rpO2Jr+7PbQ4 for <linux-nfs@vger.kernel.org>;
	Thu, 14 Jul 2011 12:50:04 -0400 (EDT)
Received: from merit.edu (pietrapertosa.merit.edu [198.108.62.155])
	by merit-proxy01.merit.edu (Postfix) with ESMTPSA id C01DF2039854
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 12:50:04 -0400 (EDT)
Date: Thu, 14 Jul 2011 12:50:04 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: block layout patches
Message-ID: <20110714165004.GA2607@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You can pull the current block layout patches from the for-trond branch of:
git://citi.umich.edu/projects/linux-pnfs-blk.git

This is based on Linux v3.0-rc5 but will soon be rebased on Trond's
nfs-for-next.

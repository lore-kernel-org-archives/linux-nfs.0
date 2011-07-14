Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:45340 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337Ab1GNQ4Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 12:56:25 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by merit-proxy02.merit.edu (Postfix) with ESMTP id 1197E2039AE9
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 12:56:25 -0400 (EDT)
Received: from merit-proxy02.merit.edu ([127.0.0.1])
	by localhost (merit-proxy02.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zJfNo0c0-6Mn for <linux-nfs@vger.kernel.org>;
	Thu, 14 Jul 2011 12:55:58 -0400 (EDT)
Received: from merit.edu (pietrapertosa.merit.edu [198.108.62.155])
	by merit-proxy02.merit.edu (Postfix) with ESMTPSA id 2125C2039879
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 12:55:49 -0400 (EDT)
Date: Thu, 14 Jul 2011 12:55:48 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: Re: block layout patches
Message-ID: <20110714165548.GB2607@merit.edu>
References: <20110714165004.GA2607@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110714165004.GA2607@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim Rees wrote:

  You can pull the current block layout patches from the for-trond branch of:
  git://citi.umich.edu/projects/linux-pnfs-blk.git
  
  This is based on Linux v3.0-rc5 but will soon be rebased on Trond's
  nfs-for-next.

Small correction: this is actually based on commit 331c925, which was the
tip of nfs-for-next until Trond released his new IO code.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:49131 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445Ab1FMSqP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 14:46:15 -0400
Date: Mon, 13 Jun 2011 14:46:12 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: block layout git repo
Message-ID: <20110613184611.GA22633@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You'll find the block layout client driver source in this git repo:

git://citi.umich.edu/projects/linux-pnfs-blk.git

The pnfs-blk-submit branch contains just the block layout driver based on
the upstream kernel (currently v3.0-rc2), and the pnfs-all-latest branch is
based on Benny's pnfs-all-latest (currently I think it's identical to
Benny's).

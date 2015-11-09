Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38216 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbbKIHwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Nov 2015 02:52:42 -0500
From: Christoph Hellwig <hch@lst.de>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: feature tests for reflink and dedup
Date: Mon,  9 Nov 2015 08:48:19 +0100
Message-Id: <1447055300-32470-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Darrick,

the patch below refines the feature checks for the new reflink and dedup
tests.


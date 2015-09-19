Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56482 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbbISWpU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Sep 2015 18:45:20 -0400
Date: Sat, 19 Sep 2015 15:45:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@mellanox.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v1 00/24] New fast registration API
Message-ID: <20150919224518.GA23027@infradead.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sagi,

I've converted the driver I'm developing to your API and it works
great.  I think this is an important step towards making the RDMA
more usable!

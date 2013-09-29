Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60027 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2MRe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:17:34 -0400
Date: Sun, 29 Sep 2013 05:17:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 29/49] pnfsd: support layout_type attribute
Message-ID: <20130929121723.GE21083@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220908-14009-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220908-14009-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Seems like layout_type should just be a field in the export ops instead
of a method.


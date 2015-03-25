Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:46721 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930AbbCYIer (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2015 04:34:47 -0400
Date: Wed, 25 Mar 2015 09:34:45 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Fix bad update of layout in
	nfsd4_return_file_layout
Message-ID: <20150325083445.GA3044@lst.de>
References: <550ECEF0.6030505@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <550ECEF0.6030505@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

Guess we need some good testcase for these artifical partial segment
returns that don't happen with the real client..

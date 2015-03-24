Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42004 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbbCXGvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2015 02:51:46 -0400
Date: Tue, 24 Mar 2015 07:51:45 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Take care the return value from
	nfsd4_encode_stateid
Message-ID: <20150324065145.GB3159@lst.de>
References: <550ECEE6.7090402@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <550ECEE6.7090402@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 22, 2015 at 10:17:10PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

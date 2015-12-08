Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:53894 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964948AbbLHPTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Dec 2015 10:19:44 -0500
Date: Tue, 8 Dec 2015 16:19:42 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [RFC PATCH 1/2] nfsd: don't hold ls_mutex across a layout
	recall
Message-ID: <20151208151942.GA4035@lst.de>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com> <1449577428-13181-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449577428-13181-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:54538 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754552AbbLVNZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Dec 2015 08:25:39 -0500
Date: Tue, 22 Dec 2015 14:25:38 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [RFC PATCH 2/2] nfsd: give up on CB_LAYOUTRECALLs after two
	lease periods
Message-ID: <20151222132538.GA25509@lst.de>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com> <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, this tests fine for me:

Tested-by: Christoph Hellwig <hch@lst.de>

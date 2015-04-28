Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:34453 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965558AbbD1MuK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 08:50:10 -0400
Received: by qkgx75 with SMTP id x75so79112000qkg.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2015 05:50:09 -0700 (PDT)
Date: Tue, 28 Apr 2015 08:50:06 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: two odstate optimizations
Message-ID: <20150428085006.7d4b9708@tlielax.poochiereds.net>
In-Reply-To: <1430222449-3921-1-git-send-email-hch@lst.de>
References: <1430222449-3921-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Apr 2015 14:00:47 +0200
Christoph Hellwig <hch@lst.de> wrote:

> Two small optimizations for the odstate handling.  Feel free to squash them
> into "nfsd: fix pNFS return on close semantics" if you need to rebase anyway.
> 

Both look good to me!

Acked-by: Jeff Layton <jeff.layton@primarydata.com>

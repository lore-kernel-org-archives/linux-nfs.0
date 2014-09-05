Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:63930 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323AbaIEOCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 10:02:08 -0400
Received: by mail-qg0-f45.google.com with SMTP id e89so11786727qgf.18
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 07:02:07 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 5 Sep 2014 10:02:04 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 12/17] locks: update Documentation/filesystems with
 new setlease semantics
Message-ID: <20140905100204.0937ad89@tlielax.poochiereds.net>
In-Reply-To: <20140904175043.GF16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-13-git-send-email-jlayton@primarydata.com>
	<20140904175043.GF16935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 10:50:43 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Looks good, but I'd rather merge it into the patch that changes the
> semantics.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Fair enough. I'll merge the changes to the Documentation in with the
patches that change them.

-- 
Jeff Layton <jlayton@primarydata.com>

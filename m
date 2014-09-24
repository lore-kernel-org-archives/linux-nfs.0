Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:48096 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbaIXPap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 11:30:45 -0400
Received: by mail-qg0-f42.google.com with SMTP id z60so4952926qgd.1
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 08:30:44 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 24 Sep 2014 11:30:41 -0400
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: refactor nfsd callback handling
Message-ID: <20140924113041.30529c18@tlielax.poochiereds.net>
In-Reply-To: <1411553959-5280-1-git-send-email-hch@lst.de>
References: <1411553959-5280-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 24 Sep 2014 12:19:15 +0200
Christoph Hellwig <hch@lst.de> wrote:

> This series reshuffles the callback code to allow for easier implementation
> of more callback operations.
> 

Nice cleanup and results in a reduction of code (which is almost always
a good thing). Looks good to me.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>

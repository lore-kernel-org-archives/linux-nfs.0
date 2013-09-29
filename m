Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f41.google.com ([74.125.82.41]:62065 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3I2MMp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:12:45 -0400
Received: by mail-wg0-f41.google.com with SMTP id l18so2419024wgh.0
        for <linux-nfs@vger.kernel.org>; Sun, 29 Sep 2013 05:12:43 -0700 (PDT)
Message-ID: <52481939.7060405@primarydata.com>
Date: Sun, 29 Sep 2013 15:12:41 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org>
In-Reply-To: <20130929114327.GB25750@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 14:43, Christoph Hellwig wrote:
> Empty header are pretty useless.

Right. This was useful early on while we re-ordered the patches that followed.
No need for that now so I'll squash this patch accordingly.

> Also why would you want a header
> outside fs/nfsd/ ?

This header contains the file system interface.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

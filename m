Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:33827 "EHLO
	mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbcHKRmB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 13:42:01 -0400
Received: by mail-qt0-f179.google.com with SMTP id u25so1403838qtb.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 10:42:01 -0700 (PDT)
Message-ID: <1470937318.30238.44.camel@redhat.com>
Subject: Re: [PATCH] nfsd: don't set a FL_LAYOUT lease for flexfiles layouts
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 11 Aug 2016 13:41:58 -0400
In-Reply-To: <20160811173846.GA26263@lst.de>
References: <1470936982-14409-1-git-send-email-jlayton@redhat.com>
	 <20160811173846.GA26263@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-08-11 at 19:38 +0200, Christoph Hellwig wrote:
> This looks fine to me, although it might be a good idea to just
> have a flags field in the layout_ops structure for additional
> quirks in the future instead of the boolean.


Sure...that's reasonable. If and when the need arises for more flags we
can always do the conversion to a flags field then as well.

I'll Bruce make the call on which he'd rather see...

-- 
Jeff Layton <jlayton@redhat.com>

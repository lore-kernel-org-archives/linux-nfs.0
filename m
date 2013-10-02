Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:57284 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab3JBO1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 10:27:19 -0400
Received: by mail-wi0-f174.google.com with SMTP id hj3so7388345wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 07:27:18 -0700 (PDT)
Message-ID: <524C2D43.6040300@primarydata.com>
Date: Wed, 02 Oct 2013 17:27:15 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 20/49] pnfsd: filelayout: layout encoding
References: <52447EA0.7070004@primarydata.com> <1380220872-13597-1-git-send-email-bhalevy@primarydata.com> <20130929121639.GD21083@infradead.org>
In-Reply-To: <20130929121639.GD21083@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 15:16, Christoph Hellwig wrote:
> The actual XDR encoding doesn't have business being under fs/exportfs
> and should be in the NFSD code itself.

But then it will create a module dependency we want to avoid.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

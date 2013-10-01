Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f43.google.com ([74.125.83.43]:50967 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab3JAGEf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 02:04:35 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so3177940eek.30
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 23:04:34 -0700 (PDT)
Message-ID: <524A65ED.5060806@primarydata.com>
Date: Tue, 01 Oct 2013 09:04:29 +0300
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

Hmm, I thought of it as in the family of fh encoding and decoding...
But I'm not married to this idea.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f180.google.com ([209.85.215.180]:52344 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab3JMGLq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 02:11:46 -0400
Received: by mail-ea0-f180.google.com with SMTP id h10so2704756eaj.11
        for <linux-nfs@vger.kernel.org>; Sat, 12 Oct 2013 23:11:45 -0700 (PDT)
Message-ID: <525A399C.5040405@primarydata.com>
Date: Sun, 13 Oct 2013 09:11:40 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map super_blocks
 to devid major identifiers
References: <52447EA0.7070004@primarydata.com> <1380220831-13136-1-git-send-email-bhalevy@primarydata.com> <20131011195608.GA18634@infradead.org>
In-Reply-To: <20131011195608.GA18634@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-11 22:56, Christoph Hellwig wrote:
> On Thu, Sep 26, 2013 at 02:40:31PM -0400, Benny Halevy wrote:
>> From: Benny Halevy <bhalevy@panasas.com>
> 
> This is entirely unessecary.  Just make sure all layouts set the sbid
> field in getdevicelist to the s_dev value of the filesystem and you
> can just use user_get_super.

That's true for filesystmes that have a meaningful s_dev, unlike exofs,
but this functionality can be added later respectively.

Benny

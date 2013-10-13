Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f178.google.com ([209.85.215.178]:49352 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab3JMGXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 02:23:54 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so2661389eae.23
        for <linux-nfs@vger.kernel.org>; Sat, 12 Oct 2013 23:23:53 -0700 (PDT)
Message-ID: <525A3C77.7030600@primarydata.com>
Date: Sun, 13 Oct 2013 09:23:51 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 21/49] nfsd: no need to unhash_stid before free
References: <52447EA0.7070004@primarydata.com> <1380220876-13642-1-git-send-email-bhalevy@primarydata.com> <20131011193721.GA4941@infradead.org>
In-Reply-To: <20131011193721.GA4941@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-11 22:37, Christoph Hellwig wrote:
> On Thu, Sep 26, 2013 at 02:41:16PM -0400, Benny Halevy wrote:
>> idr_remove is about to be called before kmem_cache_free so unhashing it
>> is redundant
>>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> This is probably something thast should go straight to Bruce, same for
> the next one in the series.
> 

True.
Bruce, are you ok with merging these patches for 3.13?

Benny

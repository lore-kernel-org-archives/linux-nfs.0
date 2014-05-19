Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:53308 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164AbaESQU7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 12:20:59 -0400
Received: by mail-ie0-f171.google.com with SMTP id rp18so2851825iec.16
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 09:20:59 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v3 00/18] nfs: support multiple requests per page
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140519153739.GA1163@infradead.org>
Date: Mon, 19 May 2014 12:20:56 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <5D146F7D-5086-4E86-A28C-1B22BC62C8E2@primarydata.com>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com> <20140519153739.GA1163@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 19, 2014, at 11:37 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, May 15, 2014 at 11:56:39AM -0400, Weston Andros Adamson wrote:
>> This patchset changes the read and write paths to be more flexible in dealing
>> with requests that are not page aligned. Until now there was a 1:1 mapping
>> of struct nfs_page (referred to as "nfs requests") to struct page, which
> 
> Any chance you could throw in a rename nfs_page to nfs_request patch
> at the end of the series?  The nfs_page name is highly confusing,
> and gets even more so with the series.
> 

I was thinking the same thing! It will be a huge change, but now is the time - we’re
changing everything else…

I’ll post in v2 of this patchset.
-dros
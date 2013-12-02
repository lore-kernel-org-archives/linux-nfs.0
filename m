Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:53735 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756221Ab3LBUpI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 15:45:08 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so22503857iec.9
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 12:45:07 -0800 (PST)
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <529CEBC3.8060505@pingtimeout.net>
Date: Mon, 2 Dec 2013 15:45:05 -0500
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
References: <529CEBC3.8060505@pingtimeout.net>
To: =?iso-8859-1?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 2, 2013, at 15:21, Antti Tönkyrä <daedalus@pingtimeout.net> wrote:

> Hello,
> 
> NTFS file system and some other filesystems seem to return EILSEQ when user passes badly formatted data. Current NFSv4 implementation does not map EILSEQ into any known NFSv4 error code which causes problems in some use cases. In my case I observed that if filesystem returns EILSEQ, the NFS share will begin I/O erroring until it's able to recover (If there are handles open to the files in the share, I/O errors will continue until they are closed after which the share recovers after small period of time).
> 
> Given that widely used ntfs-3g FUSE module also returns EILSEQ on the same case (I tested this) I would argue that a fix should be done for upstream especially since RFC5661 clearly defines that invalid UTF-8 sequence should map into NFSERR_INVAL, exact quote: "Where the client sends an invalid UTF-8 string, the server should return NFS4ERR_INVAL (see Table 5)".

The NFS client will then happily map that straight into EINVAL for you...

Cheers,
  Trond
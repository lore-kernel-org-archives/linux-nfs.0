Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36157 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab3KORAx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 12:00:53 -0500
Received: by mail-pd0-f178.google.com with SMTP id p10so3672341pdj.23
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 09:00:52 -0800 (PST)
Message-ID: <1384534841.4046.11.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
From: Trond Myklebust <trondmy@gmail.com>
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Date: Fri, 15 Nov 2013 12:00:41 -0500
In-Reply-To: <1384533481-2254-1-git-send-email-dros@netapp.com>
References: <1384533481-2254-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-15 at 11:38 -0500, Weston Andros Adamson wrote:
+AD4 decode+AF8-bitmap will only decode up to three bitmaps.  If the xdr buffer
+AD4 has more than three bitmaps, return -EIO here instead of bailing out in
+AD4 a later xdr decode.
+AD4 

No. decode+AF8-bitmap will only +AF8-save+AF8 3 words in the bitmap+AFsAXQ argment, but
it will decode arbitrary sized bitmaps:

	p +AD0 xdr+AF8-inline+AF8-decode(xdr, (bmlen +ADwAPA 2))+ADs

Cheers
  Trond


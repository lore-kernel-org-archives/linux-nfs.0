Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:57001 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab3KORGE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 12:06:04 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
Date: Fri, 15 Nov 2013 17:05:51 +0000
Message-ID: <1384535149.4046.13.camel@leira.trondhjem.org>
References: <1384533481-2254-1-git-send-email-dros@netapp.com>
	 <1384534841.4046.11.camel@leira.trondhjem.org>
In-Reply-To: <1384534841.4046.11.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-15 at 12:00 -0500, Trond Myklebust wrote:
+AD4- On Fri, 2013-11-15 at 11:38 -0500, Weston Andros Adamson wrote:
+AD4- +AD4- decode+AF8-bitmap will only decode up to three bitmaps.  If the xdr buffer
+AD4- +AD4- has more than three bitmaps, return -EIO here instead of bailing out in
+AD4- +AD4- a later xdr decode.
+AD4- +AD4- 
+AD4- 
+AD4- No. decode+AF8-bitmap will only +AF8-save+AF8- 3 words in the bitmap+AFsAXQ- argment, but
+AD4- it will decode arbitrary sized bitmaps:
+AD4- 
+AD4- 	p +AD0- xdr+AF8-inline+AF8-decode(xdr, (bmlen +ADwAPA- 2))+ADs-
+AD4- 

That said, we should probably check that the server isn't setting those
bitmap words to any non-zero values. That would be a reason to return
EIO.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:60433 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190Ab3KORMl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 12:12:41 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Weston Andros Adamson <dros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
Date: Fri, 15 Nov 2013 17:10:24 +0000
Message-ID: <1384535424.4046.15.camel@leira.trondhjem.org>
References: <1384533481-2254-1-git-send-email-dros@netapp.com>
	 <1384534841.4046.11.camel@leira.trondhjem.org>
	 <1384535149.4046.13.camel@leira.trondhjem.org>
	 <C9A7EFC4-6B93-44D4-8ADC-AAC440D4CFB2@oracle.com>
In-Reply-To: <C9A7EFC4-6B93-44D4-8ADC-AAC440D4CFB2@oracle.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-15 at 12:07 -0500, Chuck Lever wrote:
+AD4- On Nov 15, 2013, at 12:05 PM, +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Fri, 2013-11-15 at 12:00 -0500, Trond Myklebust wrote:
+AD4- +AD4APg- On Fri, 2013-11-15 at 11:38 -0500, Weston Andros Adamson wrote:
+AD4- +AD4APgA+- decode+AF8-bitmap will only decode up to three bitmaps.  If the xdr buffer
+AD4- +AD4APgA+- has more than three bitmaps, return -EIO here instead of bailing out in
+AD4- +AD4APgA+- a later xdr decode.
+AD4- +AD4APgA+- 
+AD4- +AD4APg- 
+AD4- +AD4APg- No. decode+AF8-bitmap will only +AF8-save+AF8- 3 words in the bitmap+AFsAXQ- argment, but
+AD4- +AD4APg- it will decode arbitrary sized bitmaps:
+AD4- +AD4APg- 
+AD4- +AD4APg- 	p +AD0- xdr+AF8-inline+AF8-decode(xdr, (bmlen +ADwAPA- 2))+ADs-
+AD4- +AD4APg- 
+AD4- +AD4- 
+AD4- +AD4- That said, we should probably check that the server isn't setting those
+AD4- +AD4- bitmap words to any non-zero values. That would be a reason to return
+AD4- +AD4- EIO.
+AD4- 
+AD4- Why wouldn't the client simply warn and ignore the extraneous data?
+AD4- 

...because unless the GETATTR is the very last operation, we'd end up
failing to decode things correctly. Anyway, a server that returns
attributes that we haven't requested must clearly be borken. It's
definitely violating the spec.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

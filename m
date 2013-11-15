Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:38126 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab3KOR2Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 12:28:16 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Weston Andros Adamson <dros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
Date: Fri, 15 Nov 2013 17:28:07 +0000
Message-ID: <1384536486.4046.19.camel@leira.trondhjem.org>
References: <1384533481-2254-1-git-send-email-dros@netapp.com>
	 <1384534841.4046.11.camel@leira.trondhjem.org>
	 <1384535149.4046.13.camel@leira.trondhjem.org>
	 <C9A7EFC4-6B93-44D4-8ADC-AAC440D4CFB2@oracle.com>
	 <1384535424.4046.15.camel@leira.trondhjem.org>
	 <3D7E0A6D-4009-4B28-8B43-588631A8EFD4@oracle.com>
In-Reply-To: <3D7E0A6D-4009-4B28-8B43-588631A8EFD4@oracle.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-15 at 12:23 -0500, Chuck Lever wrote:
+AD4- On Nov 15, 2013, at 12:10 PM, +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Fri, 2013-11-15 at 12:07 -0500, Chuck Lever wrote:
+AD4- +AD4APg- On Nov 15, 2013, at 12:05 PM, +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- +AD4APg- 
+AD4- +AD4APgA+- On Fri, 2013-11-15 at 12:00 -0500, Trond Myklebust wrote:
+AD4- +AD4APgA+AD4- On Fri, 2013-11-15 at 11:38 -0500, Weston Andros Adamson wrote:
+AD4- +AD4APgA+AD4APg- decode+AF8-bitmap will only decode up to three bitmaps.  If the xdr buffer
+AD4- +AD4APgA+AD4APg- has more than three bitmaps, return -EIO here instead of bailing out in
+AD4- +AD4APgA+AD4APg- a later xdr decode.
+AD4- +AD4APgA+AD4APg- 
+AD4- +AD4APgA+AD4- 
+AD4- +AD4APgA+AD4- No. decode+AF8-bitmap will only +AF8-save+AF8- 3 words in the bitmap+AFsAXQ- argment, but
+AD4- +AD4APgA+AD4- it will decode arbitrary sized bitmaps:
+AD4- +AD4APgA+AD4- 
+AD4- +AD4APgA+AD4- 	p +AD0- xdr+AF8-inline+AF8-decode(xdr, (bmlen +ADwAPA- 2))+ADs-
+AD4- +AD4APgA+AD4- 
+AD4- +AD4APgA+- 
+AD4- +AD4APgA+- That said, we should probably check that the server isn't setting those
+AD4- +AD4APgA+- bitmap words to any non-zero values. That would be a reason to return
+AD4- +AD4APgA+- EIO.
+AD4- +AD4APg- 
+AD4- +AD4APg- Why wouldn't the client simply warn and ignore the extraneous data?
+AD4- +AD4APg- 
+AD4- +AD4- 
+AD4- +AD4- ...because unless the GETATTR is the very last operation, we'd end up
+AD4- +AD4- failing to decode things correctly.
+AD4- 
+AD4- Surely that's only if the returned bitmap length doesn't match the number of bitmap words returned.  The server can return a properly encoded result without overwriting the next operation in the compound, can't it?

How do we know? You're already talking about a broken server.

+AD4- +AD4- Anyway, a server that returns
+AD4- +AD4- attributes that we haven't requested must clearly be borken. It's
+AD4- +AD4- definitely violating the spec.
+AD4- 
+AD4- Definitely, but +ACI-be lenient in what you accept.+ACI-
+AD4- 
+AD4- The reason I bring this up is that we had exactly this problem with NFSv4.2, where the third bitmap word was added.

We've never had servers returning attributes that are not requested
AFAIK. In the current code, they are free to add in as many zero fillers
in the bitmap as they want, and that's exactly what we should be
accepting.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

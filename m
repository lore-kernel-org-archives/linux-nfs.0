From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 4/5] nfsd41: set the session maximum response
	sizecached
Date: Mon, 6 Jul 2009 17:48:24 -0400
Message-ID: <20090706214824.GS1601@fieldses.org>
References: <1245872278-18743-5-git-send-email-andros@netapp.com> <5BDF2F31-6F9B-4214-95F9-4EE9B40E5538@netapp.com> <4F969509-933A-45B1-B365-CB70F812A120@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:49791
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbZGFVsV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2009 17:48:21 -0400
In-Reply-To: <4F969509-933A-45B1-B365-CB70F812A120@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 06, 2009 at 03:27:43PM -0400, Andy Adamson wrote:
> Here is what I suggest.
>
> 1) max response size should be the DRC buffer slot size (currently 512) + 
> 44 + 32. The RPC GSS verifier will still not be accounted for, but the 
> rest of the known sizes are.

Sounds good.

> 2) Perhaps bump the 512 to 512+64.  The current code shows we are  
> cutting it a bit close, we want to ensure that nfsd can service normal  
> operation responses with several GETATTR's with a lot of attributes.

576 sounds a little close too.  768?  1k?

--b.

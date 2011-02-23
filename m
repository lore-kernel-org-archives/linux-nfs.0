Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38929 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab1BWRbM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Feb 2011 12:31:12 -0500
Date: Wed, 23 Feb 2011 09:29:57 -0800
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
Message-ID: <20110223172957.GA6238@pad.home.fieldses.org>
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
 <EEB9D74B-D547-4C43-AC8B-B8B58EBD9A54@oracle.com>
 <4D653F12.8090101@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D653F12.8090101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 23, 2011 at 09:08:34AM -0800, Benny Halevy wrote:
> On 2011-02-23 08:48, Chuck Lever wrote:
> > 
> > On Feb 22, 2011, at 2:43 PM, Benny Halevy wrote:
> > 
> >> Fix bug introduced in patch
> >> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
> >>
> >> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
> >> it must account for their space in their xdr stream when calling xdr_inline_decode
> > 
> > The real problem is that decoding for the next operation in the compound will start too early in the buffer, because we didn't account for the ignored 8 bytes here, yes?
> 
> Right on the spot.

So actually I guess there is another bug here, which is a subset of

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Callback_error_handling

The server should be setting the appropriate sequence flag when it
(rightly or wrongly) things that a cb reply is garbage (not sure which
flag off the top of my head), and pynfs should be insisting that the
flag be set on any further sequence flags.

--b.

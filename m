Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216Ab1BWAZb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 19:25:31 -0500
Date: Tue, 22 Feb 2011 16:24:18 -0800
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
Message-ID: <20110223002417.GD5543@pad.home.fieldses.org>
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
 <20110223001100.GC5543@pad.home.fieldses.org>
 <4D64519A.8050604@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D64519A.8050604@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 22, 2011 at 04:15:22PM -0800, Benny Halevy wrote:
> On 2011-02-22 16:11, J. Bruce Fields wrote:
> > On Tue, Feb 22, 2011 at 02:43:22PM -0800, Benny Halevy wrote:
> >> Fix bug introduced in patch
> >> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
> >>
> >> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
> >> it must account for their space in their xdr stream when calling xdr_inline_decode
> > 
> > Thanks, applying for 2.6.38.  (How come you caught this, and I didn't?
> > I guess it's just that the object code depends more on the callback
> > returns?)
> 
> That's a great question.
> I caught it by testing cb_layoutrecall, both with the objects layout
> and with the files layout with the patch I sent for PNFSD_LEXP to recall the
> layout on truncate.
> cb_recall decoding should be broken too at the server.
> It's possible nothing really depends on its status.

Yeah, the server may take a failure as a sign it should retry the
request, but the only "reply" that really matters is the eventual
{deleg,layout,whatever}return.

On the client side a failure here would be visisble at most as a retry,
so pynfs won't catch this kind of thing.

--b.

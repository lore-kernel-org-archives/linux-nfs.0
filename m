Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30380 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651Ab1BWAPZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 19:15:25 -0500
Message-ID: <4D64519A.8050604@panasas.com>
Date: Tue, 22 Feb 2011 16:15:22 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com> <20110223001100.GC5543@pad.home.fieldses.org>
In-Reply-To: <20110223001100.GC5543@pad.home.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-22 16:11, J. Bruce Fields wrote:
> On Tue, Feb 22, 2011 at 02:43:22PM -0800, Benny Halevy wrote:
>> Fix bug introduced in patch
>> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
>>
>> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
>> it must account for their space in their xdr stream when calling xdr_inline_decode
> 
> Thanks, applying for 2.6.38.  (How come you caught this, and I didn't?
> I guess it's just that the object code depends more on the callback
> returns?)

That's a great question.
I caught it by testing cb_layoutrecall, both with the objects layout
and with the files layout with the patch I sent for PNFSD_LEXP to recall the
layout on truncate.
cb_recall decoding should be broken too at the server.
It's possible nothing really depends on its status.

Benny

> 
> --b.
> 
>>

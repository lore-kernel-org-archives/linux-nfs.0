Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f52.google.com ([209.85.216.52]:38166 "EHLO
	mail-vn0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbD2U3T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 16:29:19 -0400
Received: by vnbf1 with SMTP id f1so4872370vnb.5
        for <linux-nfs@vger.kernel.org>; Wed, 29 Apr 2015 13:29:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150429202548.GD23980@fieldses.org>
References: <5516CCDB.4020509@gmail.com>
	<20150429202548.GD23980@fieldses.org>
Date: Wed, 29 Apr 2015 16:29:18 -0400
Message-ID: <CAHQdGtTiY0C94fdre6et-r6O_ag+Hdgt0y+nfT4hd_ROvSD75Q@mail.gmail.com>
Subject: Re: [PATCH 0/4] Define common macro NFS4_MAXTAGLEN for nfs/nfsd
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 4:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Mar 28, 2015 at 11:46:35PM +0800, Kinglong Mee wrote:
>> There are four macro defines for max tag length,
>> in fs/nfs/nfs4xdr.c,
>> /* NFSv4 COMPOUND tags are only wanted for debugging purposes */
>> #ifdef DEBUG
>> #define NFS4_MAXTAGLEN                20
>> #else
>> #define NFS4_MAXTAGLEN                0
>> #endif
>>
>> in fs/nfs/callback_xdr.c,
>> #define CB_OP_TAGLEN_MAXSZ    (512)
>>
>> in fs/nfsd/xdr4.h,
>> #define NFSD4_MAX_TAGLEN      128
>>
>> in fs/nfsd/xdr4cb.h,
>> #define NFS4_MAXTAGLEN                20
>>
>> But, according to rfc3530 and rfc5661, all the length should be
>> limited by opaque limited.
>
> Neither server nor client really make any use of tags.  The client at
> least is never going to send a tag.  The server does echo back the tag
> the client received.
>
> The one arguable bug here is that the spec doesn't appear to forbid the
> server returning a non-zero-length tag when the client sent a
> zero-length tag.  And I don't think the client would handle that?
>
> If so, that might be better handled as a spec bug: if the most popular
> client has never handled it then we know that no server's ever done it.
> And it'd be annoying server behavior anyway, so, if it's de-facto
> forbidden, great.

It is a SHOULD. From RFC7530:

   The definition of the "tag" in the request is left to the
   implementer.  It may be used to summarize the content of the COMPOUND
   request for the benefit of packet sniffers and engineers debugging
   implementations.  However, the value of "tag" in the response SHOULD
   be the same value as the value provided in the request.  This applies
   to the tag field of the CB_COMPOUND procedure as well.


> In short, maybe best to just leave all this alone unless somebody's
> actually seen this cause real-world problems....

ACK. In theory, the CB_COMPOUND issue could arise on the client, but
in practice I think that we add enough padding to avoid it.

Cheers
  Trond

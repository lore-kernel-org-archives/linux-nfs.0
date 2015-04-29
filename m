Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24585 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbbD2U1W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 16:27:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 0/4] Define common macro NFS4_MAXTAGLEN for nfs/nfsd
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150429202548.GD23980@fieldses.org>
Date: Wed, 29 Apr 2015 16:28:17 -0400
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A7E22773-95E6-4A81-8E55-DD75FEE14AFC@oracle.com>
References: <5516CCDB.4020509@gmail.com> <20150429202548.GD23980@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 29, 2015, at 4:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Sat, Mar 28, 2015 at 11:46:35PM +0800, Kinglong Mee wrote:
>> There are four macro defines for max tag length, 
>> in fs/nfs/nfs4xdr.c,
>> /* NFSv4 COMPOUND tags are only wanted for debugging purposes */
>> #ifdef DEBUG
>> #define NFS4_MAXTAGLEN		20
>> #else
>> #define NFS4_MAXTAGLEN		0
>> #endif
>> 
>> in fs/nfs/callback_xdr.c,
>> #define CB_OP_TAGLEN_MAXSZ	(512)
>> 
>> in fs/nfsd/xdr4.h,
>> #define NFSD4_MAX_TAGLEN	128
>> 
>> in fs/nfsd/xdr4cb.h,
>> #define NFS4_MAXTAGLEN		20
>> 
>> But, according to rfc3530 and rfc5661, all the length should be
>> limited by opaque limited.
> 
> Neither server nor client really make any use of tags.  The client at
> least is never going

Fwiw, Solaris clients send tags.

> to send a tag.  The server does echo back the tag
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
> 
> In short, maybe best to just leave all this alone unless somebody's
> actually seen this cause real-world problems....
> 
> --b.
> 
>> 
>> The patch site defines a common macro named NFS4_MAXTAGLEN for
>> all of them, limited to opaque limited.
>> 
>> Kinglong Mee (4):
>>  nfs: define NFS4_MAXTAGLEN to OPAQUE limits
>>  nfs: use NFS4_MAXTAGLEN for cb_taglen checking
>>  nfsd: use NFS4_MAXTAGLEN for nfsd taglen checking
>>  nfsd: use NFS4_MAXTAGLEN defined in include/linux/nfs4.h
>> 
>> fs/nfs/callback_xdr.c | 5 ++---
>> fs/nfs/nfs4xdr.c      | 7 -------
>> fs/nfsd/nfs4xdr.c     | 2 +-
>> fs/nfsd/xdr4.h        | 1 -
>> fs/nfsd/xdr4cb.h      | 3 ++-
>> include/linux/nfs4.h  | 1 +
>> 6 files changed, 6 insertions(+), 13 deletions(-)
>> 
>> -- 
>> 2.3.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




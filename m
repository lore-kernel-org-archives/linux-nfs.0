Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f49.google.com ([209.85.213.49]:59071 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbbAMTmt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 14:42:49 -0500
Received: by mail-yh0-f49.google.com with SMTP id f10so2472921yha.8
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 11:42:49 -0800 (PST)
Date: Tue, 13 Jan 2015 11:42:45 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 42/49] nfs41: add range to layoutreturn args
Message-ID: <20150113194245.GB90833@kitty>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <1420590534-84063-43-git-send-email-loghyr@primarydata.com>
 <54B56EB8.2060703@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54B56EB8.2060703@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 13, 2015 at 02:15:04PM -0500, Anna Schumaker wrote:
> Hi Tao,
> 
> On 01/06/2015 07:28 PM, Tom Haynes wrote:
> > From: Peng Tao <tao.peng@primarydata.com>
> > 
> > -	lrp->args.iomode = iomode;
> > +	lrp->args.range.iomode = iomode;
> > +	lrp->args.range.offset = offset;
> > +	lrp->args.range.length = length;
> 
> Callers of pnfs_send_layoutreturn() are always passing offset = 0 and length = NFS4_MAX_UINT64.  Can we have pnfs_send_layoutreturn() always set these values, rather than passing them as function parameters?
> 

Hi Anna,

This is future-proofing - i.e., add the parameters such
that when we allow only returning part of the file we
already have the support in place.

Thanks,
Tom

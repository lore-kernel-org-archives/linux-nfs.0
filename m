Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:63559 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab0LUPrQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Dec 2010 10:47:16 -0500
Received: by bwz16 with SMTP id 16so4696544bwz.4
        for <linux-nfs@vger.kernel.org>; Tue, 21 Dec 2010 07:47:15 -0800 (PST)
In-Reply-To: <20101221152639.GC30248@infradead.org>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
	<1292898046-7336-5-git-send-email-iisaman@netapp.com>
	<20101221152639.GC30248@infradead.org>
Date: Tue, 21 Dec 2010 10:47:13 -0500
Message-ID: <AANLkTimHtMsKB1Z-LQnGebJxuOk8AMVpuANshDKG5V0D@mail.gmail.com>
Subject: Re: [PATCH 04/14] pnfs: wave 2: change layout state seqlock to a spinlock
From: Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 21, 2010 at 10:26 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Dec 20, 2010 at 09:20:36PM -0500, Fred Isaman wrote:
>> This prepares for future changes, where the layout state needs
>> to change atomically with several other variables.  In particular,
>> it will need to know if lo->segs is empty, as we test that instead
>> of manipulating the NFS_LAYOUT_STATEID_SET bit.  Moreover, the
>> layoutstateid is not really a read-mostly structure, as it is
>> written almost as often as it is read.
>
> It also renames a couple of functions.
>

I assume you refer to pnfs_get_layout_stateid ->
pnfs_choose_layoutget_stateid.  I was thinking of them as entirely
different functions, as one actually changed the stateid, and the
other doesn't.  But I can put a comment in the description clarifying
that.

Fred

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

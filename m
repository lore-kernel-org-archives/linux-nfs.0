Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41722 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189Ab1BOPHP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:07:15 -0500
Received: by wwa36 with SMTP id 36so277265wwa.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 07:07:13 -0800 (PST)
In-Reply-To: <20110215145828.GA18038@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	<1297711116-3139-9-git-send-email-andros@netapp.com>
	<20110215092531.GB29871@infradead.org>
	<AANLkTik+dVSmWgO6LRANo2xTt6iMqQ7ehvgqk-igQFhM@mail.gmail.com>
	<20110215145828.GA18038@infradead.org>
Date: Tue, 15 Feb 2011 10:07:13 -0500
Message-ID: <AANLkTi=DfuLCduGgwGrL_N5dm+y4Et9r7O511wSJw71r@mail.gmail.com>
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
From: Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: andros@netapp.com, trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 15, 2011 at 9:58 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Feb 15, 2011 at 09:48:26AM -0500, Fred Isaman wrote:
>> pnfs_free_lseg_list, besides calling free_lseg, also potentially
>> removes the layout from the clients list of inodes with layouts.
>
> Looks like the routine than changed from the mainline variant
> I looked at.  I took a quick look at the one from pnfs-submit,
> which looks quite suspicios, as it special cases the first item
> on the list without a good explanation and then iterates the list.
>

I can add a comment, but every element on the list is from the same
layout, so we just grab the layout from the first item in the list.

> Does your tree have another caller of pnfs_free_lseg_list?

Yes, there are several callers, two in callback_proc.c for example
which are both potentially actual lists.

Fred


> If not
> please just open code the right thing in the caller, instead of
> pretending we're dealing with a list if you're always dealing with
> one entry.  If the tree grows a caller that needs to deal with a list
> with more than 1 entry we can revisit if there's a point in sharing
> code.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

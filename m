From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
Date: Tue, 15 Feb 2011 09:59:25 -0500
Message-ID: <4D5A94CD.4030508@panasas.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com> <1297711116-3139-9-git-send-email-andros@netapp.com> <20110215092531.GB29871@infradead.org> <AANLkTik+dVSmWgO6LRANo2xTt6iMqQ7ehvgqk-igQFhM@mail.gmail.com> <20110215145828.GA18038@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>, andros@netapp.com,
	trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29691 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab1BOO71 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:59:27 -0500
In-Reply-To: <20110215145828.GA18038@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-02-15 09:58, Christoph Hellwig wrote:
> On Tue, Feb 15, 2011 at 09:48:26AM -0500, Fred Isaman wrote:
>> pnfs_free_lseg_list, besides calling free_lseg, also potentially
>> removes the layout from the clients list of inodes with layouts.
> 
> Looks like the routine than changed from the mainline variant
> I looked at.  I took a quick look at the one from pnfs-submit,
> which looks quite suspicios, as it special cases the first item
> on the list without a good explanation and then iterates the list.
> 
> Does your tree have another caller of pnfs_free_lseg_list?  If not
> please just open code the right thing in the caller, instead of
> pretending we're dealing with a list if you're always dealing with
> one entry.  If the tree grows a caller that needs to deal with a list
> with more than 1 entry we can revisit if there's a point in sharing
> code.
> 

Agreed.

Benny

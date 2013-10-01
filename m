Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f52.google.com ([74.125.83.52]:63413 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab3JAIcm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 04:32:42 -0400
Received: by mail-ee0-f52.google.com with SMTP id c41so3259417eek.11
        for <linux-nfs@vger.kernel.org>; Tue, 01 Oct 2013 01:32:41 -0700 (PDT)
Message-ID: <524A88A6.8030501@primarydata.com>
Date: Tue, 01 Oct 2013 11:32:38 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 29/49] pnfsd: support layout_type attribute
References: <52447EA0.7070004@primarydata.com> <1380220908-14009-1-git-send-email-bhalevy@primarydata.com> <20130929121723.GE21083@infradead.org> <524A237F.2060100@panasas.com>
In-Reply-To: <524A237F.2060100@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-01 04:21, Boaz Harrosh wrote:
> On 09/29/2013 05:17 AM, Christoph Hellwig wrote:
>> Seems like layout_type should just be a field in the export ops instead
>> of a method.
> 
> No! this field does not make any sense at all it should just be
> removed.
> 
> There is a pNFS inquiry a client sends that asks for an array
> of all the types supported by this mount point. So these method
> should be returning an array. If at all.

We're not there yet.
The pnfs generic implementation and none of the filesystems do that
at the moment.  When we go there we should revise the interface.

> 
> The layout_type is just an input to some operations and are
> no concern of NFSD. This is not a yes/no flag for pNFS the
> opts vector should be the flag.

We can push the check for the layout type down to file system
but then it will have to encode FATTR4_WORD1_FS_LAYOUT_TYPES
and FATTR4_WORD2_LAYOUT_TYPES.

Benny

> 
> Cheers
> Boaz
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

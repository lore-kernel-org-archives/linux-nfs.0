Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:10777 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215AbcEMU6N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:58:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20160501173733.GA556@infradead.org> <20160513203135.GE5658@fieldses.org>
CC: Anna Schumaker <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@primarydata.com>
Message-ID: <8d09611c-31c1-baca-8e8f-6dc599731c8c@Netapp.com>
Date: Fri, 13 May 2016 16:58:06 -0400
MIME-Version: 1.0
In-Reply-To: <20160513203135.GE5658@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/13/2016 04:31 PM, J. Bruce Fields wrote:
> On Sun, May 01, 2016 at 10:37:33AM -0700, Christoph Hellwig wrote:
>> I might sound like a broken record, but I'd feel much happier if this
>> had extensive xfstests coverage.  Xfstests has over one hundred tests for
>> file clones, and many of them should be easily adapatable.
> 
> Anna, have you looked at this yet?

Yep!  I just sent out what I came up with :)

Anna

> 
> I don't see any obvious problem with the nfsd code, other than the
> obvious issue with large synchronous copies tying up server threads and
> leaving clients waiting--but maybe we should just see how people end up
> using it and deal with the problems as they come up.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


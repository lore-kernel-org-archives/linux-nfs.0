Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:17354 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524AbbA2Qtm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jan 2015 11:49:42 -0500
Message-ID: <54CA64A3.5000105@Netapp.com>
Date: Thu, 29 Jan 2015 11:49:39 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/4] NFSD: Add READ_PLUS support
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <20150128213832.GA24389@infradead.org> <54C95860.3060109@Netapp.com>
In-Reply-To: <54C95860.3060109@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/28/2015 04:45 PM, Anna Schumaker wrote:
> On 01/28/2015 04:38 PM, Christoph Hellwig wrote:
>> On Wed, Jan 28, 2015 at 03:42:53PM -0500, Anna.Schumaker@netapp.com wrote:
>>> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>>
>>> These patches add server support for the NFS v4.2 operation READ_PLUS.
>>>
>>> I noticed a race condition in the 3rd patch when I start needing vfs_llseek()
>>> to determine if I should encode the next segment as either data or a hole.  It
>>> is possible that the file could change on us between each of the seek calls,
>>> so we don't know if we are actually at a hole or data segment.  I don't want to
>>> add new locks to the NFS server for this case, so instead I've decided to
>>> encode any "quantum data" segments as if they were actually data.
>>>
>>> I tested these patches using xfstests, specificially generic/075, generic/091,
>>> generic/112, generic/127, generic/210, and generic/263.  Additionally, three
>>> new tests are run once READ_PLUS support has been added: generic/213,
>>> generic/214, and generic/228.
>>
>> Why do theses test start working when you use READ_PLUS?  They should
>> only depend on ALLOCATE support, and maybe SEEK if we're trying to
>> figure out information about mappings somehow.
> 
> I'm not sure.  I'll rerun the tests to make sure I wasn't just confused when I typed that!

I must have been comparing v4.1 to v4.2 when I wrote that, because those tests still run without the READ_PLUS patches.  Thanks for catching that!

Anna

> 
> Anna
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


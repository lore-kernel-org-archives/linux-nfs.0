Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:57462 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab3JCOTg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 10:19:36 -0400
Received: by mail-wg0-f46.google.com with SMTP id k14so2517087wgh.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Oct 2013 07:19:35 -0700 (PDT)
Message-ID: <524D7CF3.6020306@primarydata.com>
Date: Thu, 03 Oct 2013 17:19:31 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Ric Wheeler <rwheeler@redhat.com>, Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>, Abhijith Das <adas@redhat.com>,
        Andrew Price <anprice@redhat.com>, Paul Evans <pevans@redhat.com>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org> <20131001203047.GH16245@pad.fieldses.org> <524C0556.9070705@primarydata.com> <20131002160759.GB27988@infradead.org> <524D0873.40602@primarydata.com> <20131003095511.GA30147@infradead.org> <524D6312.7020709@primarydata.com> <524D6D38.1040506@redhat.com> <20131003131750.GA23408@infradead.org> <524D6EB9.3040309@redhat.com>
In-Reply-To: <524D6EB9.3040309@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-03 16:18, Ric Wheeler wrote:
> On 10/03/2013 09:17 AM, Christoph Hellwig wrote:
>> On Thu, Oct 03, 2013 at 09:12:24AM -0400, Ric Wheeler wrote:
>>>>>> Which in-tree or soon in-tree filesystem do you care about?  And why
>>>>>> don't we see pnfs support for it submitted instead of the fairly useless
>>>>>> gfs2 support?
>>>> I picked gfs2 as the initial use case for simplicity and ease of review.
>>>> If there is a rough consensus that it's useless and not worthy of inclusion
>>>> then the one we care about the most is exofs that has a more complete pnfs
>>>> implementation.
>>>>
>>>> Benny
>>>>
>>> I don't see having GFS2 supported as a base for pNFS as useless.
>>> Christoph, is this a concern about GFS2 being too complicated for
>>> normal deployment or a lack in the pNFS support on top of it?
>> Fairly useless was specific to the particular implementation:
>>
>>   - which in the stipped down version here only supports DS access for
>>     reads
>>   - which in the previous version showed worse performance than always
>>     going through the MDS
>>
>> I don't have a problem with using GFS2 by itself, but any implementation
>> proposed should actually show signifiant real life benefits before it
>> gets merged.
>>

The question is what is the minimum value for submitting upstream...

The thing pnfs over dlm/gfs2 is missing mostly is supporting read/write layout.
One could use them load balancing, e.g. by either redirecting to a node
holding an exclusive lock on the file, if there is one, or dlm_ino_hash in its absence.

Benny

> 
> Makes sense, thanks!
> 
> Ric
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

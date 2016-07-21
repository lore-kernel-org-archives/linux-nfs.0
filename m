Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbcGUIbQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 04:31:16 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "hch@infradead.org" <hch@infradead.org>
Cc: "Trond Myklebust" <trondmy@primarydata.com>,
        "List Linux" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Thu, 21 Jul 2016 04:32:54 -0400
Message-ID: <A540F5A1-37B3-40EB-876D-EC33E891F0C9@redhat.com>
In-Reply-To: <20160721082216.GA15247@infradead.org>
References: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
 <20160719035843.GA24437@infradead.org>
 <F879054A-2116-40D5-90C9-473E71977E8A@redhat.com>
 <C44AB0DD-8FA3-42F2-B7DE-C694559A68EF@primarydata.com>
 <AB904138-E761-4F8F-AF97-0E8A4E067DB1@redhat.com>
 <20160721082216.GA15247@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21 Jul 2016, at 4:22, hch@infradead.org wrote:

> On Wed, Jul 20, 2016 at 11:03:06AM -0400, Benjamin Coddington wrote:
>>>> This debug output is identical for every cycle of the loop. Have to
>>>> stop for the
>>>> day.. more tomorrow.
>>>>
>>>> Ben
>>>>
>>>
>>> Duh??? It???s this patch: pNFS: Fix post-layoutget error handling in
>>> pnfs_update_layout()
>>> We have to pass through fatal errors??? I???ll fix it.
>>
>> That's indeed fixed it up, and generic/207 passes now.  Thanks!
>
> So I spoke too soon in my last mail, generic/207 still fails for me
> with Trond's linux-next tree, although much later in the test now.
>
> Does it include the changes that are supposed to fix the issue?

It should -- the v2 that fixed 207 for me is 
56b38a1f7c781519eef09c1668a3c97ea911f86b, the first version was 
e35c2a0b3cd062a8941d21511719391b64437427, I think.  I'll test again too.

Ben

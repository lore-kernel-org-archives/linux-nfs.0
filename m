From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related	headers
Date: Wed, 11 Nov 2009 19:59:21 +0200
Message-ID: <4AFAFB79.1070805@panasas.com>
References: <4ADEC1EF.8040107@panasas.com> <1256112873-32495-1-git-send-email-bharrosh@panasas.com> <1256171298.6809.1.camel@heimdal.trondhjem.org> <4AE01569.9000002@panasas.com> <1256220146.6402.23.camel@heimdal.trondhjem.org> <4AE08165.2040100@panasas.com> <20091104220927.GS11637@fieldses.org> <4AFAD0EA.2080909@panasas.com> <20091111173638.GC3128@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:48957 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758018AbZKKR7T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 12:59:19 -0500
In-Reply-To: <20091111173638.GC3128@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/11/2009 07:36 PM, J. Bruce Fields wrote:
> On Wed, Nov 11, 2009 at 04:57:46PM +0200, Boaz Harrosh wrote:
>> On 11/05/2009 12:09 AM, J. Bruce Fields wrote:
>>> On Thu, Oct 22, 2009 at 05:59:33PM +0200, Boaz Harrosh wrote:
>>>
>>> I'm assuming Trond's objection is just to the patch changelog
>>> (specifically, to the statement that any header "should be compilation
>>> independent"), not to these specific changes.
>>>
>>> --b.
>>
>> Ping
>>
>> Bruce? Trond? whatsup?
>>
>> Can Benny put these patches in his tree? He said he would be happy to hold
>> them for a while, but only if they will be eventually accepted into the
>> tree as a pnfs pre-requisite. Please ACK on these patches?
>>
>> I have to make all these put-the-includes-back patches to just make the tree
>> compile.
> 
> They're fine by me.
> 
> (Can't speak for Trond, but maybe his initial objection would be met
> just editing the changelog to replace the absolute "Any header should be
> compilation independent" by the particular advantages you saw in this
> case.)
> 

I don't see why. Please advise? 

"should be compilation independent", from what I understand of the English
language, is suggestive and advisory only. Now, if I was using "must" or
"shall" like the standard do then that would mean a mandatory directive.
But I'm only saying "should" which is like saying: "I suggest", or
"it is recommended". Am I misunderstanding the language?

Any way the commit log is just my saying so, my sign-off it's not the word
of Linux-god, is it?

> --b.
> 
>>
>> Boaz
>>

Thanks
Boaz

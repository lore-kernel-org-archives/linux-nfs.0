From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH 2/2] NFSD: Added TEST_STATEID operation
Date: Tue, 12 Jul 2011 08:40:11 -0400
Message-ID: <4E1C40AB.2040503@netapp.com>
References: <1305922380-8162-1-git-send-email-bjschuma@netapp.com> <1305922380-8162-3-git-send-email-bjschuma@netapp.com> <4E0B81B6.8060005@netapp.com> <20110629195447.GC3279@fieldses.org> <4E0B8C5E.1090505@netapp.com> <20110629204058.GA6894@fieldses.org> <20110712105946.GB2162@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21036 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091Ab1GLMkM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 08:40:12 -0400
In-Reply-To: <20110712105946.GB2162@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/2011 06:59 AM, J. Bruce Fields wrote:
> On Wed, Jun 29, 2011 at 04:40:59PM -0400, J. Bruce Fields wrote:
>> On Wed, Jun 29, 2011 at 04:34:38PM -0400, Bryan Schumaker wrote:
>>> On 06/29/2011 03:54 PM, J. Bruce Fields wrote:
>>>> On Wed, Jun 29, 2011 at 03:49:10PM -0400, Bryan Schumaker wrote:
>>>>> On 05/20/2011 04:13 PM, bjschuma@netapp.com wrote:
>>>>>> +__be32
>>>>>> +nfsd4_do_test_stateid(stateid_t *stateid, int flags)
>>>>>> +{
>>>>>> +	__be32 ret = nfs4_validate_stateid(stateid, flags);
>>>>>> +	if (!ret)
>>>>>> +		ret = nfs4_validate_stateid(stateid, flags);
>>>>>> +	return ret;
>>>>>
>>>>> Looking back at this, I'm not convinced that I need to call nfs4_validate_stateid() twice with the same stateid and flags.  What is the status of these patches?  Should I resubmit everything or send in a small patch to fix this?
>>>>
>>>> Whoops, lazy review on my part....
>>>>
>>>> Looks like I'd applied that locally but not pushed it out to my public
>>>> tree yet, so I could still take a replacement.
>>>
>>> Ok, sounds good.
>>>>
>>>> How are you testing these, by the way?  On second thoughts, I think I
>>>> may have already asked you that, and forgotten the answer, so don't
>>>> bother answering here--just add some text to the changelog and then I'll
>>>> know how to find the answer next time.
>>>
>>> I found this as I was going through my fault injection code.  I'm going to double check these with my fault injection changes and then try to send in updates for both next week.
>>
>> Sounds good, thanks Bryan.--b.
> 
> Are those still on the way?  (Or did you send and I missed them?  If so,
> if you wouldn't mind resending....)

I sent them out last Friday.  I'll resend.

- Bryan
> 
> --b.


From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related headers
Date: Thu, 22 Oct 2009 17:59:33 +0200
Message-ID: <4AE08165.2040100@panasas.com>
References: <4ADEC1EF.8040107@panasas.com>	 <1256112873-32495-1-git-send-email-bharrosh@panasas.com>	 <1256171298.6809.1.camel@heimdal.trondhjem.org>	 <4AE01569.9000002@panasas.com> <1256220146.6402.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:6243 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751074AbZJVP7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2009 11:59:33 -0400
In-Reply-To: <1256220146.6402.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/2009 04:02 PM, Trond Myklebust wrote:
> On Thu, 2009-10-22 at 10:18 +0200, Boaz Harrosh wrote:
>> On 10/22/2009 02:28 AM, Trond Myklebust wrote:
>>> On Wed, 2009-10-21 at 10:14 +0200, Boaz Harrosh wrote:
>>>> An header should be compilation independent, .i.e pull in
>>>> any header who's declarations are directly used by this header.
>>>> And not let users re-include all it's dependencies all over
>>>> again.
>>>>
>>>> [At the end of the day what's the use of a header if it does
>>>>  not have more then one user?]
>>>
>>>
>>> The problem with this is that you quickly end up including the same
>>> header files over and over and over again as they get pulled in several
>>> times over by different headers.
>>>
>>>
>>>
>>
>> What is the problem with that?
>>
>> two things:
>> 1. it is unavoidable.
>> 2. That's why we invented the #ifndef FOO_H #define FOO_H for.
>> 3. Look at the current mess, to the point that you don't understand why
>>    the code does not compile, you end up just copy-past the include list
>>    of that other file, and now actually do end with extra un-needed includes.
>>    (Don't believe me look at the last patch as proof).
>> 4. So I add to an header a use of a type that now needs a new include.
>>    All my users do not compile any more. What to do? OK I'll include it so
>>    not to change all existing users all over again. Now we get a double
>>    standard. All headers used before any users, must be carried around.
>>    The late comers are escaped.
>> 5. The opposite of 4. An header is no longer needed. Extra header left at all
>>    users.
>>
>> It used to be a problem before me and you have begun programing.
>> Since then the cpp looks at it's internal structures and will not re-open.
>> Note that the compiler never sees the second instance, ever.
>>
>> That said we have no choice of the matter. It is a Kernel style guide. I
>> should know because I was banged on the head with it a couple of times.
>> And rightly so.
>>
>> Come on that was a joke right
>> Boaz
> 
> No. What I'm saying is that this doesn't have to be an absolute rule.
> The Kernel style guide assumes that everything in 'include/*' is going
> to be exported all around the kernel.
> The problem is that we put a lot of stuff which is private to fs/nfs and
> fs/nfsd in there. Those header files do not have to absolutely follow
> the style guide rule, 'cos we know what is being included before and
> after them...
> 

I'm not sure I understand
You are saying that the patches are very good, but only
the rule I stated originally could be relaxed a little with private
headers where we might get lazy, if the effects are very local?

Well, that's not a problem then, right? just that I can relax a bit
if I want.

But I disagree: see 3, 4, 5 above and that last patch I submitted. That patch
is only the beginning. 85% of all source files in nfs/nfsd could receive the
same love. I only done these I touched. Code tends to stay much-much longer
then we spend time on it. Better get it in shape the first time.

> Cheers
>   Trond
> 

I've now compiled this with x86 allmodeconfig. It should stay in linux-next for a while
to make sure there's no side effects.

Boaz

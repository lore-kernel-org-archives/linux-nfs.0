Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:16486 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbaCFUiP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 15:38:15 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <00D4C447-07C9-4FBA-ABD6-285C97727316@primarydata.com>
Date: Thu, 6 Mar 2014 15:38:10 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0C5C1EB7-C494-4D82-B8C9-A6141CD592E9@oracle.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306123438.GA21799@umich.edu> <04BE61B0-08B5-4E0C-88B6-6D93127BB64E@oracle.com> <5B1102FE-8521-4BEF-8A2B-CE17EC32777F@primarydata.com> <17607EE5-614A-4B13-B5E7-0D1344A30C7F@oracle.com> <2A4F9722-1ED1-462E-B66B-669217957814@primarydata.com> <473B4660-0C59-49D4-8BBD-24ABD929AFB9@oracle.com> <BB585E65-78D2-45D9-9513-BB988686F1A9@primarydata.com> <228A4E31-65A8-4357-937E-24554B5B3835@oracle.com> <00D4C447-07C9-4FBA-ABD6-285C97727316@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 12:47 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Mar 6, 2014, at 11:45, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Mar 6, 2014, at 11:16 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> 
>>> On Mar 6, 2014, at 11:13, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> 
>>>> On Mar 6, 2014, at 11:02 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>> 
>>>>> 
>>>>> On Mar 6, 2014, at 10:59, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>> 
>>>>>> 
>>>>>> On Mar 6, 2014, at 10:33 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>>>> 
>>>>>>> 
>>>>>>> On Mar 6, 2014, at 10:26, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>> 
>>>>>>>> 
>>>>>>>> On Mar 6, 2014, at 7:34 AM, Jim Rees <rees@umich.edu> wrote:
>>>>>>>> 
>>>>>>>>> Given this is apache, I think if I were doing this I'd use ro,soft,intr,tcp
>>>>>>>>> and not try to write anything to nfs.
>>>>>>>> 
>>>>>>>> I agree. A static web page workload should be read-mostly or read-only. The (small) corruption risk with “ro,soft" is that an interrupted read would cause the client to cache incomplete data.
>>>>>>> 
>>>>>>> What? How? If that were the case, we would have a blatant read bug. As I read the current code, _any_ error will cause the page to not be marked as up to date.
>>>>>> 
>>>>>> Agree, the design is sound. But we don’t test this use case very much, so I don’t have 100% confidence that there are no bugs.
>>>>> 
>>>>> Is that the royal ‘we’, or are you talking on behalf of all the QA departments and testers here? I call bullshit…
>>>> 
>>>> If you want to differ with my opinion, fine. But your tone is not professional or appropriate for a public forum. You need to start treating all of your colleagues with respect, including me.
>>>> 
>>>> If anyone else had claimed a testing gap, you would have said “If that were the case, we would have a blatant read bug” and left it at that. But you had to go one needless and provocative step further.
>>>> 
>>>> Stop bullying me, Trond. I’ve had enough of it.
>>> 
>>> The stop spreading FUD. That is far from professional too.
>> 
>> FUD is a marketing term, and implies I had intent to deceive. Really?
>> 
>> I expressed a technical opinion, with a degree of uncertainty, just like everyone else does. People who ask questions here are free to take our advice or not, based on their own experience. They are adults, they read “IMO” where it is implied.
>> 
>> It is absolutely your right to say that I’m incorrect, or to clarify something I said. If you have test data that shows "ro,soft,tcp" cannot possibly cause any version of the Linux NFS client to cache corrupt data, show it, without invective. That is an appropriate response to my remark.
>> 
>> Face it, you over-reacted. Again. Knock it off.
>> 
> 
> You clearly don’t know what other people are testing with, and you clearly didn’t ask anyone before you started telling users that 'soft' is untested.

I suggested in a reply TO YOU that perhaps this use case was untested...

> I happen to know a server vendor for which _all_ internal QA tests are done using the ‘soft’ mount option on the clients. This is done for practical reasons in order to prevent client hangs if the server should panic.

… and that’s all you needed to say in response. But you have chosen to turn it into a shouting match because you read more into my words than was there.

> I strongly suspect that other QA departments are testing the ’soft' case too.

“I strongly suspect” means you don’t know for sure either.

Clearly Andrew and Brian are reporting a problem here, whether or not it’s related to data corruption, and vendor testing has not found it yet, apparently. I’m not surprised. Testing is difficult, and too often it finds only exactly what you’re looking for.

(On the technical issue, just using “soft” does not constitute a robust test. Repeatedly exercising the soft timeout is not the same as having “soft” in play “just in case” the server panics.)

> Acting as if you are an authoritative source on the subject of testing, when you are not and you know that you are not, does constitute intentional deception, yes.

No-one is "acting like an authority on testing," except maybe you.

What possible reason could I have for deceiving anyone about my authority or anything else? Do you understand that calling someone a liar in public is deeply offensive? Do you understand how unnecessarily humiliating your words are?

Assuming that you do understand, the level of inappropriate heat here is a sign that you have a long-standing personal issue with me. You seem to always read my words as a challenge to your authority, and that is never what I intend. There is nothing I can do about your mistaken impression of me.

> …and no, I don’t see anything above to indicate that this was an ‘opinion’ on the subject of what is being tested which is precisely why I called it.

LOL. You “called it” because my claim that testing wasn’t sufficient touched a nerve.

Are you really suggesting we all need to add “IMO” and a giant .sig disclaimer to everything we post to this list, or else Trond will swat us with a rolled up newspaper if he doesn’t happen to agree?

--
Chuck Lever




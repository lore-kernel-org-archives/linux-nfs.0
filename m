Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17946 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932396AbdHWSgi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Aug 2017 14:36:38 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 1/3] nfsd: Limit end of page list when decoding NFSv4 WRITE
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170822214513.GA28543@fieldses.org>
Date: Wed, 23 Aug 2017 14:36:33 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C680E88E-B51D-464C-AC4C-5F9C0B31ED9B@oracle.com>
References: <20170818150957.26571.12169.stgit@klimt.1015granger.net> <20170818151219.26571.31977.stgit@klimt.1015granger.net> <20170821211359.GA14949@fieldses.org> <BC15F5B8-7B61-4A0C-8F80-2513FB6C12EF@oracle.com> <20170821212140.GB14949@fieldses.org> <4307538A-9A23-4F8D-AC80-BA850E6422E5@oracle.com> <20170822214513.GA28543@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 22, 2017, at 5:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Mon, Aug 21, 2017 at 06:08:15PM -0400, Chuck Lever wrote:
>> 
>>> On Aug 21, 2017, at 5:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Mon, Aug 21, 2017 at 05:15:38PM -0400, Chuck Lever wrote:
>>>> 
>>>>> On Aug 21, 2017, at 5:13 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>> 
>>>>> On Fri, Aug 18, 2017 at 11:12:19AM -0400, Chuck Lever wrote:
>>>>>> When processing an NFSv4 WRITE operation, argp->end should never
>>>>>> point past the end of the data in the final page of the page list.
>>>>>> Otherwise, nfsd4_decode_compound can walk into uninitialized memory.
>>>>>> 
>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>> ---
>>>>>> fs/nfsd/nfs4xdr.c |    6 ++----
>>>>>> 1 file changed, 2 insertions(+), 4 deletions(-)
>>>>>> 
>>>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>>>> index 51e729a..7c48d68 100644
>>>>>> --- a/fs/nfsd/nfs4xdr.c
>>>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>>>> @@ -144,7 +144,7 @@ static void next_decode_page(struct nfsd4_compoundargs *argp)
>>>>>> 	argp->p = page_address(argp->pagelist[0]);
>>>>>> 	argp->pagelist++;
>>>>>> 	if (argp->pagelen < PAGE_SIZE) {
>>>>>> -		argp->end = argp->p + (argp->pagelen>>2);
>>>>>> +		argp->end = argp->p + XDR_QUADLEN(argp->pagelen);
>> 
>>                     ^^^^^^^^^^^^^^ A
>> 
>>>>>> 		argp->pagelen = 0;
>>>>>> 	} else {
>>>>>> 		argp->end = argp->p + (PAGE_SIZE>>2);
>>>>>> @@ -1279,9 +1279,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>>>>>> 		argp->pagelen -= pages * PAGE_SIZE;
>>>>>> 		len -= pages * PAGE_SIZE;
>>>>>> 
>>>>>> -		argp->p = (__be32 *)page_address(argp->pagelist[0]);
>>>>>> -		argp->pagelist++;
>>>>>> -		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
>> 
>>                     ^^^^^^^^^^^^^^ B
>> 
>>>>>> +		next_decode_page(argp);
>>>>> 
>>>>> I think there's no change in behavior here *except* for adding a new
>>>>> argp->pagelen=0 (or argp->pagelen -= PAGE_SIZE).
>>>> 
>>>> The code around this change is currently working correctly,
>>>> so there is no change in behavior AFAICT. This is a defensive
>>>> change, but it also replaces duplicate code.
>>> 
>>> I don't understand.  I'm saying that by calling next_decode_page() there
>>> you've added a new argp->pagelen assignment.  I don't understand how
>>> that can't change behavior, unless there's another bug in our bounds
>>> checking someplace.
>> 
>> Because of line B above, argp->end always points to the
>> end of the final page in the page list. However, the
>> buffer might end somewhere in the middle of that page,
>> in which case, the transport hasn't initialized any of
>> the bytes between the end of the buffer and the end of
>> the page.
>> 
>> As long as the other fields in the xdr_buf are set up
>> properly, the XDR decoder will not walk into that uninit-
>> ialized section of the last page. But there's nothing
>> preventing a decoder or transport bug from causing it
>> to walk into the uninitialized area. And always setting
>> to the end of the page is confusing when the buffer
>> itself is actually shorter.
>> 
>> The key is to replace line B above with line A. argp->end
>> is advanced by the remaining part of the final page rather
>> than by a whole page.
> 
> Got it, I agree with that part of the change, it's the pagelen change I
> was having trouble with.
> 
> But looking at it more, I think your patch is a fix and the current code
> is wrong.
> 
>> The next patch uses this new behavior to signal precisely
>> when it has to move from the page list to the tail iovec.
>> 
>> 
>>> Most likely it could cause subsequent op parsers to believe there's less
>>> space in the argument buffer than there really is, so it might fail to
>>> parse a compound with a write plus some other ops, if that puts the
>>> total call close to the maximum size?
>> 
>> Where is argp->pagelen used after the final next_decode_page
>> call?
> 
> Well, it's checked in every read_buf and next_decode_page to decide how
> much space is left.

Right, and I didn't change the pagelen adjustment that occurs
in the loop. Just the final adjustment should be different.


> It looks to me like the current code is wrong not to be decreasing
> page_len at the end there.  So I wonder if there's a bug right now.
> E.g. maybe a compound with multiple writes could leave the xdr decoding
> thinking it has more space than it does and allow someone to write
> unrelated memory to some file.

I believe that's possible.


--
Chuck Lever




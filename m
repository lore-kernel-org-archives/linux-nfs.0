Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:60390 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab1LUWuN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Dec 2011 17:50:13 -0500
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C21@IT-1874.Isys.com>
Date: Wed, 21 Dec 2011 17:50:00 -0500
Cc: Jeff Layton <jlayton@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <C7069B98-95DA-4BE5-8883-11640EFF4427@oracle.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com> <1324499696-10318-5-git-send-email-jlayton@redhat.com> <46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com> <20111221163312.3405c1f3@tlielax.poochiereds.net> <121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com> <20111221164810.78d600a9@tlielax.poochiereds.net> <20111221165922.589101aa@tlielax.poochiereds.net> <FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C18@IT-1874.Isys.com> <FB145782-E1E4-4BEE-9CD4-EF5653A77A91@oracle.com> <FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C21@IT-1874.Isys.com>
To: Peter Staubach <pstaubach@exagrid.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 21, 2011, at 5:31 PM, Peter Staubach wrote:

> Hi.
> 
> I can't really specify things either, but XDR parsing of something which is fixed in size and format is much less overhead than parsing of strings.  Even adding for the possibility of versioning, XDR is going to come out vastly easier to implement.

In the kernel, not so much.  We always have to code either text-based or XDR-based encoding or decoding by hand there.  The only benefit is in user space, if you can integrate machine-built rpcgen stubs with your code.  The text-based helpers in nfs-utils are not hard to use, though.

> Text string parsing is very nice when variable strings are passed, in varying orders, with some appearing and others not.  In this case, all fields must be present.  There isn't any benefit to passing them in random orders, so it appears that the primary benefit of the text string parsing is minimized.

There is some argument variability.  There is a union in Jeff's data structure.

But again, I'm not religious, I actually like XDR for many things.  Here I think it's simply useful to be consistent with what is already in place.  Text-based APIs also have an observability advantage; in fact, you can write scripts to text-based APIs a lot easier than you can to XDR-based ones.

If we go with XDR for this API, the natural question an impartial reviewer might ask is "why does this NFSD API use XDR but others of equal or greater complexity do not?"  I might be more inclined to choose XDR for this application if there was some commitment to converting some of the other NFSD user space APIs.

> 	Thanx...
> 
> 		ps
> 
> 
> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com] 
> Sent: Wednesday, December 21, 2011 5:22 PM
> To: Peter Staubach
> Cc: Jeff Layton; bfields@fieldses.org; steved@redhat.com; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
> 
> 
> On Dec 21, 2011, at 5:04 PM, Peter Staubach wrote:
> 
>> By text based, you don't really mean encoding the binary structure as a string of ascii hex bytes, right?  Bleah.
> 
> No, I mean something akin to what is done for the other NFSD upcall and downcall arguments and results.  A single set of decimal digits for simple arguments, and "keyword=value keyword=value,value" and so on for complex arguments.  I recommend text because that is similar to what is used for every other modern user space API that NFSD has.
> 
>> I would suggest that XDR encoding seems quite natural to use when passing binary structs around.
> 
> To be clear, there is just one binary data item here, and that's nfs_client_id4.  The other data items are integers, which have well-defined text representations.
> 
> A new and separate API without any legacy baggage might be XDR, but text seems more appropriate here given the existence of other text APIs.  I'm not religious about this, just highlighting a few design choices.
> 
>> 	Thanx...
>> 
>> 		ps
>> 
>> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org 
>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Jeff Layton
>> Sent: Wednesday, December 21, 2011 4:59 PM
>> To: Jeff Layton
>> Cc: Chuck Lever; bfields@fieldses.org; steved@redhat.com; 
>> linux-nfs@vger.kernel.org
>> Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to 
>> nfsdcld
>> 
>> On Wed, 21 Dec 2011 16:48:10 -0500
>> Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> On Wed, 21 Dec 2011 16:37:30 -0500
>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> 
>>>> On Dec 21, 2011, at 4:33 PM, Jeff Layton wrote:
>>>> 
>>>>> On Wed, 21 Dec 2011 15:45:01 -0500 Chuck Lever 
>>>>> <chuck.lever@oracle.com> wrote:
>>>>> 
>>>>>> 
>>>>>> On Dec 21, 2011, at 3:34 PM, Jeff Layton wrote:
>>>>>> 
>>>>>>> The daemon takes a versioned binary struct. Hopefully this should 
>>>>>>> allow us to revise the struct later if it becomes necessary.
>>>>>> 
>>>>>> This breaks the pattern of using text-based up- and downcalls in NFSD.  I assume this is binary because nfs_client_id4 is a string of opaque bytes?
>>>>>> 
>>>>> 
>>>>> That's the main reason. We could, of course encode that string in 
>>>>> hex or something, and decode it on the other end. No one has 
>>>>> presented a strong argument for doing it that way as of yet though.
>>>>> 
>>>>> If anyone feels strongly about that, then it would be helpful to 
>>>>> have them pipe up now and state why they do...
>>>> 
>>>> <pipe>Because binary data structures are difficult to work with over 
>>>> time, which is why other NFSD user space interfaces are 
>>>> text-based.</pipe>
>>>> 
>>>> ;-)
>>>> 
>>> 
>>> *sigh* that was the sort of comments I was hoping to get out of the 
>>> RFC postings. But ok...
>>> 
>>> I'll see about respinning the whole thing with either a text-based or 
>>> XDR-based upcall/downcall format. That'll take a while, but I'll see 
>>> if I can get it in shape in time for 3.3.
>>> 
>> 
>> ...and while we're discussing it. Does anyone have thoughts on which would be better? I'd probably prefer a text-based format. That's more flexible but is also going to be more verbose. I think we're still well under a page with these requests even in text however so I don't really see that as a problem.
>> 
>> --
>> Jeff Layton <jlayton@redhat.com>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
>> in the body of a message to majordomo@vger.kernel.org More majordomo 
>> info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Mon, 12 Oct 2009 15:34:22 -0400
Message-ID: <4AD384BE.2090008@redhat.com>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4ACB5FC0.7060307@redhat.com> <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org> <4AD36C82.8080904@redhat.com> <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: James Morris <jmorris@namei.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932469AbZJLTfF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 15:35:05 -0400
In-Reply-To: <CA06CB5C-6084-45AA-B185-FBDA7E3B9754-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Haynes wrote:
> 
> 
> Sent from my iPhone
> 
> On Oct 12, 2009, at 10:50 AM, Peter Staubach <staubach@redhat.com> wrote:
> 
>> James Morris wrote:
>>> On Tue, 6 Oct 2009, Peter Staubach wrote:
>>>
>>>>> Three operations are implemented by the new XATTR protocol and map to
>>>>> syscalls:
>>>>>
>>>>> - GETXATTR     getxattr(2)
>>>>> - LISTXTTR     listxattr(2)
>>>>> - SETXATTR     setxattr(2) and removexattr(2)
>>>>>
>>>>> This code passes basic testing of the above syscalls, although
>>>>> there are
>>>>> some areas which still need work:
>>>>>
>>>> Is there a set of tests which are used to test this functionality?
>>>
>>> No, I just manually run a set of commands to verify basic behavior.
>>>
>>> I gather LTP would be the best place to add tests for this?
>>>
>>>>> - Interoperability with other OSs (we probably should at least
>>>>>   discuss with BSD folk)
>>>>>
>>>> It would be good to include the BSD folks, but I think that more
>>>> valuable targets would be those with volume servers that might be
>>>> encountered at customer sites.  I think that we need NetApp, EMC,
>>>> perhaps Sun, providing some feedback on the protocol and semantics.
>>>
>>> Given that IETF activity is closed for v3, I wonder what the best forum
>>> would be to reach all these folk?
>>>
>>
>> With some sort of protocol description, it should be possible to
>> publish some sort of document.  Off hand, I don't know what it
>> might be called, but we can find out.
>>
>> Otherwise, we might be able to get by with a .x description of
>> the over the wire protocol and some short words describing the
>> expected semantics of anything that non-Linux implementators
>> might need to be aware of.
>>
>> I know that (at least) a few non-Linux folks lurk here.  Might
>> any of them have any opinions regarding the viability of
>> implementing this support on their own implementations?  TomH?
>> MichaelE?
>>
> 
> Amazing to find my name in the middle of a thread.
> 

Or at least part of it...  :-)

> I've just got what is in this email...
> 

Hmmm.  I wonder why this and not the others.  Oh well.

> So, is this a new side band protocol or an extension to NFSv3?
> 

This is a side band protocol designed to allow the setting
and getting of Linux style extended attributes.  They don't
quite match the Solaris style sub-files approach, but I
think could be implemented on top of the sub-files approach.

> Is there some document describing the problem being solved?
> 

Not exactly, or at least, not that I've seen.  There is a need
to support general Linux style extended attributes over NFSv3
and NFSv4 prior to 4.2.  This will be used in the short term
to solve some of the base issues that are being addressed by
the Labeled NFS work currently underway in the IETF WG.  That
work is much more extensive and designed to be a better
solution, but we need something before that work will complete.

I am seeking to discover whether this will be a Linux to
Linux only solution always or whether other vendors might be
amenable to considering implementing this support.

	Thanx, Tom.

		ps

> 
> 
> 
> 
> 
>>>>> - Caching of xattrs at the client
>>>>>
>>>> This will need a closer specification for the semantics associated
>>>> with these xattrs.  The need will be how to determine when to
>>>> invalidate cached xattrs.
>>>
>>> I suspect user namespace xattrs should be treated like file data wrt
>>> caching (i.e. they're fully under the control of the user).
>>>
>>
>> Umm, I think that some more detail might be required.  For
>> example, when the file contents are modified, the mtime on
>> the file is supposed to change.  I am wondering what in the
>> metadata for the file itself changes when an extended attribute
>> is added, modified, or deleted.  It is this information that we
>> can use to then do correct cache validation and invalidation.
>>
>> I am assuming that the ctime changes, but we need to explicitly
>> ensure that this is true or discover what else is.
>>
>> I believe that without caching, the performance of any resulting
>> implementations will not be acceptable.
>>
>>>> On more bullet that I might suggest is ensuring that the protocol
>>>> is compliant with the RPC and XDR standards.
>>>
>>
>> I believe that http://tools.ietf.org/html/rfc5531#appendix-B
>> describes the portion of this that pertains to obtaining a
>> registered RPC program number.  Otherwise, ensuring that all
>> of the data structures are encoded according to the XDR
>> specifications and that all byte orders are encoded according
>> to the same specification should suffice.
>>
>>    Thanx...
>>
>>        ps
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html


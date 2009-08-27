From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Reference to file size in nfsd_create_v3
Date: Thu, 27 Aug 2009 11:49:36 +0530
Message-ID: <4A962578.5000509@gluster.com>
References: <4A449074.6060600@gluster.com> <20090825161845.GD26206@fieldses.org> <4A94DFDA.4040508@gluster.com> <4A953AE6.1030800@redhat.com> <20090826160444.GC18070@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Peter Staubach <staubach@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.datasyncintra.net ([208.88.241.29]:59567 "EHLO
	saturn.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbZH0GTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2009 02:19:03 -0400
In-Reply-To: <20090826160444.GC18070@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Aug 26, 2009 at 09:38:46AM -0400, Peter Staubach wrote:
>> Shehjar Tikoo wrote:
>>> J. Bruce Fields wrote:
>>>> On Fri, Jun 26, 2009 at 02:40:12PM +0530, Shehjar Tikoo wrote:
>>>>> Hi All
>>>>>
>>>>> I am looking at the fs/nfsd/vfs.c:nfsd_create_v3 function. In
>>>>> there, a comment says: "furthermore, if the size is nonzero, we
>>>>> should ignore it according to spec!"
>>>>>
>>>>> Could someone please point out the section in RFC1813 where this
>>>>> particular point is specified?
>>>> It's referring to the third paragraph of the DESCRIPTION section of
>>>> the OPEN operation (14.2.16) in rfc 3530.
>>>>
>>>> --b.
>>> Ok.
>>>
>>> For NFSv3, is there a specified way to handle create or mkdir ops where
>>>  the size is non-zero? The reason this came up is that I was testing
>>> unfs3 with SpecSFS2k8 and an MKDIR op failed in unfs3 because SFS sent
>>> the mkdir call with non-zero size in the attributes. I just wanted to
>>> see how Linux nfsd handled it.
> 
> But you've only seen the problem against unfs3, not against the kernel
> nfsd?
> 

I didnt test SFS against the kernel nfsd so cant comment on it.

>> Most servers in the market just ignore the size field for
>> MKDIR requests.  They also ignore the size field, unless it is
>> 0, for CREATE requests.
> 
> So it's probably a bug on both sides.  (SpecSFS shouldn't be sending a
> non-zero size either.)
> 

Yes, I fixed the problem in unfs3 by making it ignore the size in
the MKDIR request. SpecSFS might need further investigation.

Thanks
-Shehjar

> --b.
> 
>> Setting the size on a directory does not make sense and the
>> usual decision point for file creation is whether to truncate
>> the file to empty or not.
>>
>> 		ps
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html



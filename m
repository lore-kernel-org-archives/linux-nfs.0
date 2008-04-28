From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] NFS limits?
Date: Mon, 28 Apr 2008 12:06:19 -0400
Message-ID: <5FFAAFB8-DB6B-413C-9BEF-29C20EFD6C82@oracle.com>
References: <480C8DAB.40504@cesca.es> <480C9A1B.20604@redhat.com>
	<480CA2CC.80209@cesca.es> <4815AA4B.1080304@cesca.es>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
To: Jordi Prats <jprats-KO9VOOLprG0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58466 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965623AbYD1SLH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Apr 2008 14:11:07 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JqXob-0003am-O0
	for linux-nfs@vger.kernel.org; Tue, 29 Apr 2008 04:11:01 +1000
In-Reply-To: <4815AA4B.1080304-KO9VOOLprG0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2008, at 6:43 AM, Jordi Prats wrote:
> Hi all,
> Witch are the limits of NFSv3 and NFSv4?

If you are using NFSv3, then this may not be an NFS limitation at  
all.  I seem to recall that some Linux kernels had issues with file  
systems larger than 2TB.

Which kernel version are you using?

> I was wrong about the version I was using, we are currently using  
> NFSv3.
> Anyone is exporting by NFS a filesystem as large (or larger) as our?
>
> Thanks,
> Jordi
>
> Jordi Prats wrote:
>> Hi Peter,
>> My boss is reluctant to upgrade this server, so I'm stuck to NFSv2 : 
>> ( I
>> hope this will convince him !
>>
>> Thanks,
>> Jordi
>>
>> Peter Staubach wrote:
>>
>>> Jordi Prats wrote:
>>>
>>>> Hi all,
>>>> I've a 4246 GB (above 4TB) using NFSv2 to export it. Some  
>>>> application
>>>> are generating estrange errors, so it's possible I'm facing a NFS
>>>> limit? How large can a be to be exported without problems?
>>>>
>>>> I'm using a 32bits architecture.
>>>>
>>>> Thanks!
>>>> Jordi
>>>>
>>>>
>>>>
>>> NFSv2 is a 32 bit file access protocol, so don't be surprised
>>> if you see EFBIG sorts of errors on operations such as FSSTAT.
>>>
>>> In particular, that file system size is too large to represent,
>>> I am sort of surprised that it would even be mountable.
>>>
>>> Why not use NFSv3 or NFSv4?
>>>
>>>      ps

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


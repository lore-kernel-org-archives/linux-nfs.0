From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 15:34:35 -0400
Message-ID: <5FC6E83A-4D26-4A77-B3F0-E34A9E97E9B5@oracle.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com> <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com> <1250962724.8143.29.camel@heimdal.trondhjem.org> <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com> <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com> <1251115893.6325.23.camel@heimdal.trondhjem.org> <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com> <1251226809.25372.29.camel@heimdal.trondhjem.org> <d4098e2f0908251206o34590902u9a69aed32142d67e@mail.gmail.com> <1251227539.25372.35.camel@heimdal.trondhjem.org> <d4098e2f0908251219w42340c9ak4538a22f8d7391b6@mail.gmail.com> <1251228350.25372.36.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:30102 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098AbZHYTet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 15:34:49 -0400
In-Reply-To: <1251228350.25372.36.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 25, 2009, at 3:25 PM, Trond Myklebust wrote:
> On Tue, 2009-08-25 at 21:19 +0200, Stefan Egli wrote:
>> On Tue, Aug 25, 2009 at 9:12 PM, Trond Myklebust wrote:
>>> On Tue, 2009-08-25 at 21:06 +0200, Stefan Egli wrote:
>>>> On Tue, Aug 25, 2009 at 9:00 PM, Trond Myklebust wrote:
>>>>> Yes. The NFS client will cache mtime whether or not you do an  
>>>>> 'ls'. I
>>>>> suspect the only reason for the 'ls' in that launchpad bug  
>>>>> report, is to
>>>>> force an mtime update (and to fill the readdir cache).
>>>>
>>>> Ok, interesting. I guess though that 'something' needs to read at  
>>>> least
>>>> a file in that particular directory for the directory content to be
>>>> cached, right? (i.e. either an 'ls' or some create/delete of a  
>>>> file?)
>>>
>>> Every time you use a filename, the act of looking up that name is
>>> cached. The parent directory's mtime is also cached. If it  
>>> changes, then
>>> the cached lookup is invalidated. If not, then the cached lookup is
>>> assumed still valid (since the directory contents are not supposed  
>>> to
>>> have changed).
>>
>> Great thanks, got that!
>>
>> Is there some docu about this level of NFS detail you know of?
>> Esp the attribute and the data cache?
>
> There should be some information (perhaps a bit out of date, but  
> most of
> it good) in the old FAQ here: http://nfs.sourceforge.net/

nfs(5) has an extensive addendum on metadata caching.  An upcoming  
update will document the lookupcache behavior.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

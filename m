From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Fix send buffer length calculation in nfs3_xdr_setaclargs()
Date: Thu, 16 Apr 2009 14:00:19 -0400
Message-ID: <A0B34AA3-DD6B-4A30-8A8B-833DAEA6BEF9@oracle.com>
References: <49E5EAE6.7000507@suse.de> <1239818456.5177.88.camel@heimdal.trondhjem.org> <49E6BF7C.8040505@suse.de> <5E1C743F-6C25-47E6-9658-4868EDFD8771@oracle.com> <1239900127.4198.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Suresh Jayaraman <sjayaraman@suse.de>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27564 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756281AbZDPSik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 14:38:40 -0400
In-Reply-To: <1239900127.4198.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 16, 2009, at 12:42 PM, Trond Myklebust wrote:
> On Thu, 2009-04-16 at 09:52 -0400, Chuck Lever wrote:
>> On Apr 16, 2009, at 1:17 AM, Suresh Jayaraman wrote:
>>> Trond Myklebust wrote:
>>>> On Wed, 2009-04-15 at 19:40 +0530, Suresh Jayaraman wrote:
>>>>> The recent posixacl fix(commit
>>>>> ae46141ff08f1965b17c531b571953c39ce8b9e2)
>>>>> seems to have introduced a bug that will lead to -EINVAL errors
>>>>> during
>>>>> normal setfacl operations on file or dir. This patch attempts to  
>>>>> fix
>>>>> this.
>>>>
>>>> To start with, your len_in_head is in units of 32-bit _words_,
>>>> whereas
>>>> len, base, and req->rq_slen are in units of bytes.
>>>>
>>>> Then, 'len' is initialised to the length of the currently encoded
>>>> part
>>>> of the RPC header before subtracting 'len_in_head'. The resulting
>>>> number
>>>
>>> Doh, I got it wrong totally. Thanks for the explaination.
>>>
>>> On a side note, I think it would be nice to add little comments in  
>>> xdr
>>> code to explain non-obvious pieces.
>>
>> As an aside, I think implementing this with xdr_streams might have
>> some clarity benefits.
>
> Possibly, but right now, I just want to merge the one-liner fix into
> 2.6.30-rc2 and 2.6.29-stable...

No rush, just a suggestion.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

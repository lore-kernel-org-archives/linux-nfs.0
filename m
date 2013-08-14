Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mercury.cora.nwra.com ([4.28.99.165]:56331 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933191Ab3HNVJl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Aug 2013 17:09:41 -0400
Message-ID: <520BE844.9030408@cora.nwra.com>
Date: Wed, 14 Aug 2013 14:27:48 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpc.idmapd: nss_getpwnam: name '#' does not map into domain
References: <loom.20130814T210744-290@post.gmane.org>  <loom.20130814T212246-502@post.gmane.org> <1376510917.29258.55.camel@leira.trondhjem.org>
In-Reply-To: <1376510917.29258.55.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/14/2013 02:08 PM, Myklebust, Trond wrote:
> On Wed, 2013-08-14 at 19:24 +0000, Orion Poplawski wrote:
>> Orion Poplawski <orion@...> writes:
>>
>>>
>>> On our EL6 nfs servers we see periodic messages like:
>>>
>>> Aug 14 12:55:19 alexandria rpc.idmapd[19237]: nss_getpwnam: name '612' does
>>> not map into domain 'cora.nwra.com'
>>>
>>> I imagine that this is caused by a client actually passing the uid instead
>>> of the username for some reason but I have no idea how to track down which.
>>>   Any ideas?
>
> Are you seeing any _actual_ application errors?

Not that I'm aware of.

>> These *appear* to be triggered by the following types of requests:
>>
>>
>> Network File System, Ops(3): PUTFH SETATTR GETATTR
>
> That is 100% expected behaviour if you are using AUTH_SYS on the client
> (see the explanation in RFC3530bis). The default there is to use
> unmapped uids and gids for backward compatibility with NFSv3, and to
> ensure that the names/groups used by NFSv4 match the uids/gids used by
> the AUTH_SYS authentication.
>
> In the case where the NFSv4 server doesn't support that mode of
> operation, it is expected to return NFS4ERR_BADOWNER (although Linux
> clients also accept NFS4ERR_BADNAME) in which case the client will
> switch to using mapped ids.

Thanks, finally came across that.  I'm wondering if it is worth changing 
libnfsidmap to not log this message in these cases.



-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder/CoRA Office             FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com

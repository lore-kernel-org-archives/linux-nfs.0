Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:32511 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753726Ab2KZFej convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 00:34:39 -0500
Message-ID: <50B300EC.5020707@cn.fujitsu.com>
Date: Mon, 26 Nov 2012 13:41:00 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs cache bug (when server delete the file ,nfs client can read
 file also)
References: <50AEF92B.4080900@cn.fujitsu.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F07@SACEXCMBX04-PRD.hq.netapp.com> <50AF0850.6060901@cn.fujitsu.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F85@SACEXCMBX04-PRD.hq.netapp.com> <50AF10ED.3070208@cn.fujitsu.com> <20121123172056.GA8776@fieldses.org>
In-Reply-To: <20121123172056.GA8776@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bfields@fieldses.org 写道:
> On Fri, Nov 23, 2012 at 02:00:13PM +0800, fanchaoting wrote:
>> Myklebust, Trond 写道:
>>> On Fri, 2012-11-23 at 13:23 +0800, fanchaoting wrote:
>>>> Myklebust, Trond 写道:
>>>>> On Fri, 2012-11-23 at 12:18 +0800, fanchaoting wrote:
>>>>>> I think  when the nfs server delete the file ,
>>>>>> the  server should notice the nfs client,
>>>>>> but the upstream kernel does't this.
>>>>> So is this a problem with the client or the server? In other words, if
>>>>> you use a different server/client combination, do you see a different
>>>>> result?
>>>>>
>>>> I think that the server has the problem .when the server deletes the file ,
>>>> it should notice the client immediately.
>>> There is no notification mechanism in NFS; on open(), the client is
>>> supposed to revalidate its cached information and the server is supposed
>>> to return an ESTALE error if the filehandle is no longer valid. Either
>>> one of these 2 mechanisms (client revalidation or server reply) could be
>>> going wrong here, which is why I'm asking.
>> I found J. Bruce Fields's patch(break delegations on unlink)  maybe solve this problem .
>> But I did't found it in the upstream kernel.
> 
> Yes, still working on getting that merged.  Next step is probably to
> rebase it on top of jlayton's ESTALE patches, assuming those will go in
> first.  In theory they could make 3.8 but that may be optimistic.
> 

Yes, when I applyed the patch, this problem was solved.
I found when server deleted the file , it can return 
"DELEGRETURN" to the nfs client.

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 




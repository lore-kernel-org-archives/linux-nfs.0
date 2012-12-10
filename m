Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36987 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab2LJJR2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2012 04:17:28 -0500
Message-ID: <50C5A889.2080604@parallels.com>
Date: Mon, 10 Dec 2012 13:16:57 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <linux-kernel@vger.kernel.org>, <devel@openvz.org>
Subject: Re: [Devel] [PATCH 3/6] nfsd: pass net to nfsd_create_serv()
References: <20121204134920.24504.95261.stgit@localhost.localdomain> <20121204135016.24504.74168.stgit@localhost.localdomain> <20121207165211.GK17115@fieldses.org> <50C59C68.30803@parallels.com>
In-Reply-To: <50C59C68.30803@parallels.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.12.2012 12:25, Stanislav Kinsbursky пишет:
> 07.12.2012 20:52, J. Bruce Fields пишет:
>> On Tue, Dec 04, 2012 at 04:50:16PM +0300, Stanislav Kinsbursky wrote:
>>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>>> index 21cba3d..6448391 100644
>>> --- a/fs/nfsd/nfssvc.c
>>> +++ b/fs/nfsd/nfssvc.c
>>> @@ -334,10 +334,9 @@ static int nfsd_get_default_max_blksize(void)
>>>       return ret;
>>>   }
>>>
>>> -int nfsd_create_serv(void)
>>> +int nfsd_create_serv(struct net *net)
>>>   {
>>>       int error;
>>> -    struct net *net = &init_net;
>>
>> What does this apply to?  Since 3.6-rc1 we have
>> 57c8b13e3cd0f94944c9691ce7f58e5fcef8a12d "NFSd: set nfsd_serv to NULL
>> after service destruction" which includes:
>>
>> @@ -332,6 +330,7 @@ static int nfsd_get_default_max_blksize(void)
>>   int nfsd_create_serv(void)
>>   {
>>          int error;
>> +       struct net *net = current->nsproxy->net_ns;
>>
>>          WARN_ON(!mutex_is_locked(&nfsd_mutex));
>>          if (nfsd_serv) {
>>
>> Am I missing some later patch?
>>
>
> Maybe I'm missing something.
> My tree is based on yours branch "for-3.8".
> Doe I need to rebase?
>

My bad, sorry.
I forgot to send one patch in this series.

>> --b.
>>
>
>


-- 
Best regards,
Stanislav Kinsbursky

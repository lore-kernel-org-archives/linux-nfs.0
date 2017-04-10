Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752144AbdDJK6P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 06:58:15 -0400
Subject: Re: [PATCH] systemd: nfs-server service should use network-online
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170407150738.6200-1-steved@redhat.com>
 <87shlhxdzq.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e75ecc27-3e53-f643-160a-cdf121518121@RedHat.com>
Date: Mon, 10 Apr 2017 06:58:13 -0400
MIME-Version: 1.0
In-Reply-To: <87shlhxdzq.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/09/2017 09:12 PM, NeilBrown wrote:
> On Fri, Apr 07 2017, Steve Dickson wrote:
> 
>> There has been an number startup problems where parts of
>> the NFS server fail to start due to DNS and other
>> parts of the network not be up.
>>
>> Reading the systemd.special it seems network.target is
>> a passive unit which does not wait and network-online.target
>> is an active unit which does not wait so that
>> should be used.
> 
> I assume that last "not" should not be there?
Right... 
> 
> According to systemd.special, we should add
>   Wants=network-online.target
> though "Requires" is probably OK.
I did see that... but the bug report said After= 
worked so I went with that... 

> 
> nfs-server.service already has
>  Requires= network.target
> which you didn't change.
> 
> Also nfs-mountd rpc-statd-notify and rpc.statd all have
>  After = network.target
> 
> They should probably be changed too ??
yup... good call.

steved.

> 
> Thanks,
> NeilBrown
> 
> 
>>
>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1419351
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  systemd/nfs-server.service | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
>> index 5be5de6..7cf4ae0 100644
>> --- a/systemd/nfs-server.service
>> +++ b/systemd/nfs-server.service
>> @@ -7,8 +7,8 @@ Wants=rpcbind.socket
>>  Wants=rpc-statd.service nfs-idmapd.service
>>  Wants=rpc-statd-notify.service
>>  
>> -After= local-fs.target
>> -After= network.target proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
>> +After= local-fs.target network-online.target
>> +After= proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
>>  After= nfs-idmapd.service rpc-statd.service
>>  Before= rpc-statd-notify.service
>>  
>> -- 
>> 2.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

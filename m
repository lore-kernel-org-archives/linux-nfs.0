Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:40787 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422829Ab2KNNXR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 08:23:17 -0500
Message-ID: <50A39B2D.6070206@parallels.com>
Date: Wed, 14 Nov 2012 17:22:53 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/15] nfsd: make reclaim_str_hashtbl allocated per net
References: <20121113154722.12577.57671.stgit@localhost.localdomain> <20121113154833.12577.8139.stgit@localhost.localdomain> <20121114080247.67cd6b45@tlielax.poochiereds.net>
In-Reply-To: <20121114080247.67cd6b45@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

14.11.2012 17:02, Jeff Layton пишет:
> On Tue, 13 Nov 2012 18:48:33 +0300
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
>
<snip>
>>
>> +
>> +static int
>> +nfs4_legacy_state_init(struct net *net)
>> +{
>> +     struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>> +     int i;
>> +
>> +     nn->reclaim_str_hashtbl = kmalloc(sizeof(struct list_head) *
>> +                                       CLIENT_HASH_SIZE, GFP_KERNEL);
>> +     if (!nn->reclaim_str_hashtbl)
>> +             return -ENOMEM;
>> +
>> +     for (i = 0; i < CLIENT_HASH_SIZE; i++)
>> +             INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
>> +     nn->reclaim_str_hashtbl_size = 0;
>> +
>> +     return 0;
>> +}
>> +
>> +static void
>> +nfs4_legacy_state_shutdown(struct net *net)
>> +{
>> +     struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>> +
>> +     kfree(nn->reclaim_str_hashtbl);
>> +}
>> +
>>   static int
>>   nfsd4_load_reboot_recovery_data(struct net *net)
>>   {
>> @@ -425,13 +454,23 @@ nfsd4_load_reboot_recovery_data(struct net *net)
>>                return -EINVAL;
>>        }
>>
>> +     status = nfs4_legacy_state_init(net);
>> +     if (status)
>> +             return status;
>> +
>
> nit: might be clearer to create a new legacy ->init function and have
> it call the state_init and then load the recovery data.
>

Yep, sure.

>
> Looks like a reasonable and good change, but may need reconciling with
> the patches from me that Bruce merged recently into his for-next tree.
>

Thanks. Already working on it.

-- 
Best regards,
Stanislav Kinsbursky

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:49446 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab3L3JWy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Dec 2013 04:22:54 -0500
Message-ID: <52C13B22.90109@parallels.com>
Date: Mon, 30 Dec 2013 13:21:38 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Weng Meiling <wengmeiling.weng@huawei.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, <stable@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <lizefan@huawei.com>,
        <h.huangqiang@huawei.com>, "Eric W. Biederman" <ebiederm@xmission.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Subject: Re: NFSd 3.13 bug (Was "Re: [PATCH 3.4 9/9] nfsd: use the current
 net ns in write_threads() and write_ports()")
References: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com> <1386136415-30976-10-git-send-email-wengmeiling.weng@huawei.com> <20131204212532.GB19452@fieldses.org> <52A686A7.8060208@huawei.com> <52AE56D7.5010302@huawei.com> <52AF1BE4.1090702@parallels.com> <52C13720.5070205@huawei.com>
In-Reply-To: <52C13720.5070205@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

30.12.2013 13:04, Weng Meiling пишет:
> Hi Stanislav,
>
> I test kernel with this patch, the problem has be fixed. Would you please send a
> formal one? :) Thanks very much!
>

Thank you, Weng!
Sure, I'll resend.

> Weng Meiling
> Thanks
>
> On 2013/12/16 23:27, Stanislav Kinsbursky wrote:
>> 16.12.2013 05:26, Weng Meiling пишет:
>>> I backport the patch 11f779421a39b86da8a523d97e5fd3477878d44f "nfsd: containerize NFSd
>>>> filesystem" and test. But I trigger a bug, this bug still exists in 3.13 kernel. The following
>>>> is what I do:
>>>>
>>>> The steps:
>>>>
>>>> step 1: start NFS server in init_net net ns
>>>> #service nfsserver start
>>>>
>>>> step 2: stop NFS server in non init_net net ns
>>>> #ip netns add test
>>>> #ip netns list
>>>> test
>>>> #ip netns exec test service nfsserver stop
>>>>
>>>> step 3: start NFS server again in the non init_net net ns
>>>> #ip netns exec test service nfsserver start
>>>>
>>>> This step 3 will trigger kernel panic.
>>
>>
>> This sequence can be reduced to steps 2 and 3.
>>
>>
>>>> The reason seems that "ip
>>>> netns exec" creates a new mount namespace, the changes to the
>>>> new mount namespace don't propgate to other namespaces. So
>>>> when stop NFS server in second step, the NFSD filesystem isn't
>>>> umounted.  When restart NFS server in third step, the NFSD
>>>> filesystem will not remount,  this result to the NFSD file
>>>> system superblock's net ns is still init_net and RPCBIND client
>>>> will be NULL when register RPC service with the local portmapper
>>>> in svc_addsock(). Do you have any ideas about this problem?
>>>>
>>
>> The problem here is that on NFS server stop, RPCBIND client were destroyed for init_net,
>> because network namespace context is being taken from NFSd superblock.
>> On NFS start start rpc.nfsd process creates socket in nested net and passes it into "write_ports",
>> which leads to NFSd creation of RPCBIND socket in init_net because of the same reason. An attempt
>> to register passed socket in nested net leads to panic. I think, this collusion should be handled
>> as error and can be fixed like below.
>>
>> BTW, it looks to me. that mounts with namespace-aware superblocks can't just use the same
>> superblock on new mount namespace creation and should be handled in more complex way.
>>
>> Eric, Al, could you share your opinion how this problem should be solved?
>>
>> =======================================================================================
>>
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 7f55517..f34d9de 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -699,6 +699,11 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
>>          if (err != 0 || fd < 0)
>>                  return -EINVAL;
>>
>> +       if (svc_alien_sock(net, fd)) {
>> +               printk(KERN_ERR "%s: socket net is different to NFSd's one\n", __func__);
>> +               return -EINVAL;
>> +       }
>> +
>>          err = nfsd_create_serv(net);
>>          if (err != 0)
>>                  return err;
>> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
>> index 62fd1b7..947009e 100644
>> --- a/include/linux/sunrpc/svcsock.h
>> +++ b/include/linux/sunrpc/svcsock.h
>> @@ -56,6 +56,7 @@ int           svc_recv(struct svc_rqst *, long);
>>   int            svc_send(struct svc_rqst *);
>>   void           svc_drop(struct svc_rqst *);
>>   void           svc_sock_update_bufs(struct svc_serv *serv);
>> +bool           svc_alien_sock(struct net *net, int fd);
>>   int            svc_addsock(struct svc_serv *serv, const int fd,
>>                                          char *name_return, const size_t len);
>>   void           svc_init_xprt_sock(void);
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index b6e59f0..3ba5b87 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -1397,6 +1397,17 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>>          return svsk;
>>   }
>>
>> +bool svc_alien_sock(struct net *net, int fd)
>> +{
>> +       int err;
>> +       struct socket *sock = sockfd_lookup(fd, &err);
>> +
>> +       if (sock && (sock_net(sock->sk) != net))
>> +               return true;
>> +       return false;
>> +}
>> +EXPORT_SYMBOL_GPL(svc_alien_sock);
>> +
>>   /**
>>    * svc_addsock - add a listener socket to an RPC service
>>    * @serv: pointer to RPC service to which to add a new listener
>>
>>
>>
>>
>
>


-- 
Best regards,
Stanislav Kinsbursky

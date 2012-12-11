Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36660 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257Ab2LKONN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 09:13:13 -0500
Message-ID: <50C73F58.1080005@parallels.com>
Date: Tue, 11 Dec 2012 18:12:40 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
References: <20121206153204.30693.11408.stgit@localhost.localdomain> <20121206153447.30693.54128.stgit@localhost.localdomain> <20121210202842.GB17350@fieldses.org> <50C73C60.8060405@parallels.com>
In-Reply-To: <50C73C60.8060405@parallels.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.12.2012 18:00, Stanislav Kinsbursky пишет:
> 11.12.2012 00:28, J. Bruce Fields пишет:
>> On Thu, Dec 06, 2012 at 06:34:47PM +0300, Stanislav Kinsbursky wrote:
>>> NFSd does lookup. Lookup is done starting from current->fs->root.
>>> NFSd is a kthread, cloned by kthreadd, and thus have global (but luckely
>>> unshared) root.
>>> So we have to swap root to those, which process, started NFSd, has. Because
>>> that process can be in a container with it's own root.
>>
>> This doesn't sound right to me.
>>
>> Which lookups exactly do you see being done relative to
>> current->fs->root ?
>>
>
> Ok, you are right. I was mistaken here.
> This is not a exactly lookup, but d_path() problem in svc_export_request().
> I.e. without root swapping, d_path() will give not local export path (like "/export")
> but something like this "/root/containers_root/export".
>

We, actually, can do it less in less aggressive way.
I.e. instead root swap and current svc_export_request() implementation:

void svc_export_request(...)
{
	<snip>
         pth = d_path(&exp->ex_path, *bpp, *blen);
	<snip>
}

we can do something like this:

void svc_export_request(...)
{
	struct nfsd_net *nn = ...
	<snip>
	spin_lock(&dcache_lock);
         pth = __d_path(&exp->ex_path, &nn->root, *bpp, *blen);
	spin_unlock(&dcache_lock);
	<snip>
}

>> --b.
>>
>>>
>>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>>> ---
>>>   fs/nfsd/netns.h  |    1 +
>>>   fs/nfsd/nfssvc.c |   33 ++++++++++++++++++++++++++++++++-
>>>   2 files changed, 33 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>>> index abfc97c..5c423c6 100644
>>> --- a/fs/nfsd/netns.h
>>> +++ b/fs/nfsd/netns.h
>>> @@ -101,6 +101,7 @@ struct nfsd_net {
>>>       struct timeval nfssvc_boot;
>>>
>>>       struct svc_serv *nfsd_serv;
>>> +    struct path    root;
>>>   };
>>>
>>>   extern int nfsd_net_id;
>>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>>> index cee62ab..177bb60 100644
>>> --- a/fs/nfsd/nfssvc.c
>>> +++ b/fs/nfsd/nfssvc.c
>>> @@ -392,6 +392,7 @@ int nfsd_create_serv(struct net *net)
>>>
>>>       set_max_drc();
>>>       do_gettimeofday(&nn->nfssvc_boot);        /* record boot time */
>>> +    get_fs_root(current->fs, &nn->root);
>>>       return 0;
>>>   }
>>>
>>> @@ -426,8 +427,10 @@ void nfsd_destroy(struct net *net)
>>>       if (destroy)
>>>           svc_shutdown_net(nn->nfsd_serv, net);
>>>       svc_destroy(nn->nfsd_serv);
>>> -    if (destroy)
>>> +    if (destroy) {
>>> +        path_put(&nn->root);
>>>           nn->nfsd_serv = NULL;
>>> +    }
>>>   }
>>>
>>>   int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
>>> @@ -533,6 +536,25 @@ out:
>>>       return error;
>>>   }
>>>
>>> +/*
>>> + * This function is actually slightly modified set_fs_root()<F9>
>>> + */
>>> +static void nfsd_swap_root(struct net *net)
>>> +{
>>> +    struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>> +    struct fs_struct *fs = current->fs;
>>> +    struct path old_root;
>>> +
>>> +    path_get(&nn->root);
>>> +    spin_lock(&fs->lock);
>>> +    write_seqcount_begin(&fs->seq);
>>> +    old_root = fs->root;
>>> +    fs->root = nn->root;
>>> +    write_seqcount_end(&fs->seq);
>>> +    spin_unlock(&fs->lock);
>>> +    if (old_root.dentry)
>>> +        path_put(&old_root);
>>> +}
>>>
>>>   /*
>>>    * This is the NFS server kernel thread
>>> @@ -559,6 +581,15 @@ nfsd(void *vrqstp)
>>>       current->fs->umask = 0;
>>>
>>>       /*
>>> +     * We have to swap NFSd kthread's fs->root.
>>> +     * Why so? Because NFSd can be started in container, which has it's own
>>> +     * root.
>>> +     * And so what? NFSd lookup files, and lookup start from
>>> +     * current->fs->root.
>>> +     */
>>> +    nfsd_swap_root(net);
>>> +
>>> +    /*
>>>        * thread is spawned with all signals set to SIG_IGN, re-enable
>>>        * the ones that will bring down the thread
>>>        */
>>>
>
>


-- 
Best regards,
Stanislav Kinsbursky

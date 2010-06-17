From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 01/19] SQUASHME: pnfs-submit: merge pnfs4_proc_setattr
 	into nfs4_proc_setattr
Date: Thu, 17 Jun 2010 11:12:02 -0400
Message-ID: <4C1A3B42.2060603@panasas.com>
References: <4C1A3570.5030709@panasas.com>	<1276786099-11300-1-git-send-email-bhalevy@panasas.com> <AANLkTika4BAGrDg0CnUPRy9Qji6rThr5zcZ0S8ciAr29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:8028 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760235Ab0FQPL5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:11:57 -0400
In-Reply-To: <AANLkTika4BAGrDg0CnUPRy9Qji6rThr5zcZ0S8ciAr29-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 17, 2010, 11:00 -0400, Fred Isaman <iisaman@umich.edu> wrote:
> On Thu, Jun 17, 2010 at 10:48 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |   35 +++++++++++++++--------------------
>>  1 files changed, 15 insertions(+), 20 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 8c02296..17a2597 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2333,6 +2333,19 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
>>        return err;
>>  }
>>
>> +static void
>> +pnfs4_return_layout_on_setattr(struct inode *inode)
>> +{
>> +#ifdef CONFIG_NFS_V4_1
>> +       struct nfs_server *server = NFS_SERVER(inode);
>> +       struct nfs_inode *nfsi = NFS_I(inode);
>> +
>> +       if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
> 
> pnfs_enabled_sb() is not needed given the following has_layout() test.
> 

Good point. I'll remove it.

Benny

> Fred
> 
>> +           pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
>> +               pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
>> +#endif /* CONFIG_NFS_V4_1 */
>> +}
>> +
>>  /*
>>  * The file is not closed if it is opened due to the a request to change
>>  * the size of the file. The open call will not be needed once the
>> @@ -2359,6 +2372,8 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>>        struct nfs4_state *state = NULL;
>>        int status;
>>
>> +       pnfs4_return_layout_on_setattr(inode);
>> +
>>        nfs_fattr_init(fattr);
>>
>>        /* Search for an existing open(O_WRITE) file */
>> @@ -2378,25 +2393,6 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>>        return status;
>>  }
>>
>> -#ifdef CONFIG_NFS_V4_1
>> -/*
>> - * Return layout before issueing a setattr
>> - */
>> -static int
>> -pnfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>> -                   struct iattr *sattr)
>> -{
>> -       struct inode *inode = dentry->d_inode;
>> -       struct nfs_server *server = NFS_SERVER(inode);
>> -       struct nfs_inode *nfsi = NFS_I(inode);
>> -
>> -       if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
>> -           pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
>> -               pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
>> -       return nfs4_proc_setattr(dentry, fattr, sattr);
>> -}
>> -#endif /* CONFIG_NFS_V4_1 */
>> -
>>  static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *dirfh,
>>                const struct qstr *name, struct nfs_fh *fhandle,
>>                struct nfs_fattr *fattr)
>> @@ -6068,7 +6064,6 @@ pnfs_v4_clientops_init(void)
>>        struct nfs_rpc_ops *p = (struct nfs_rpc_ops *)&pnfs_v4_clientops;
>>
>>        memcpy(p, &nfs_v4_clientops, sizeof(*p));
>> -       p->setattr              = pnfs4_proc_setattr;
>>        p->read_done            = pnfs4_read_done;
>>        p->write_setup          = pnfs4_proc_write_setup;
>>        p->write_done           = pnfs4_write_done;
>> --
>> 1.6.4.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

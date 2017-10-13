Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:52692 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdJMU5o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Oct 2017 16:57:44 -0400
Received: by mail-ua0-f194.google.com with SMTP id i35so6148377uah.9
        for <linux-nfs@vger.kernel.org>; Fri, 13 Oct 2017 13:57:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171013205550.65573-5-kolga@netapp.com>
References: <20171013205550.65573-1-kolga@netapp.com> <20171013205550.65573-5-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 13 Oct 2017 16:57:42 -0400
Message-ID: <CAN-5tyG_sP=Bp9U8O8YUm6FuWqmyoPYGfE+YABohd60aBf0+xQ@mail.gmail.com>
Subject: Re: [PATCH v5 04/23] NFS OFFLOAD_STATUS op
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 13, 2017 at 4:55 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs42.h     |  5 ++++-
>  fs/nfs/nfs42proc.c | 43 +++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 47 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> index b6cd153..6b9decf 100644
> --- a/fs/nfs/nfs42.h
> +++ b/fs/nfs/nfs42.h
> @@ -11,6 +11,7 @@
>   */
>  #define PNFS_LAYOUTSTATS_MAXDEV (4)
>
> +#if defined(CONFIG_NFS_V4_2)
>  /* nfs4.2proc.c */
>  int nfs42_proc_allocate(struct file *, loff_t, loff_t);
>  ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
> @@ -19,5 +20,7 @@
>  int nfs42_proc_layoutstats_generic(struct nfs_server *,
>                                    struct nfs42_layoutstat_data *);
>  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
> -
> +int nfs42_proc_offload_status(struct file *, nfs4_stateid *,
> +                             struct nfs42_offload_status_res *);
> +#endif /* CONFIG_NFS_V4_2) */
>  #endif /* __LINUX_FS_NFS_NFS4_2_H */
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 6c2db51..65fb014 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -263,6 +263,49 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
>         return err;
>  }
>
> +int _nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
> +                               struct nfs42_offload_status_res *res)
> +{
> +       struct nfs42_offload_status_args args = {
> +               .osa_src_fh = NFS_FH(file_inode(dst)),
> +       };
> +       struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
> +       struct rpc_message msg = {
> +               .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OFFLOAD_STATUS],
> +               .rpc_resp = res,
> +               .rpc_argp = &args,
> +       };
> +       int status;
> +
> +       memcpy(&args.osa_stateid, stateid, sizeof(args.osa_stateid));
> +       status = nfs4_call_sync(dst_server->client, dst_server, &msg,
> +                               &args.osa_seq_args, &res->osr_seq_res, 0);
> +       if (status == -ENOTSUPP)
> +               dst_server->caps &= ~NFS_CAP_OFFLOAD_STATUS;
> +
> +       return status;
> +}
> +
> +int nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
> +                               struct nfs42_offload_status_res *res)
> +{
> +       struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
> +       struct nfs4_exception exception = { };
> +       int status;
> +
> +       if (!(dst_server->caps & NFS_CAP_OFFLOAD_STATUS))
> +               return -EOPNOTSUPP;
> +
> +       do {
> +               status = _nfs42_proc_offload_status(dst, stateid, res);
> +               if (status == -ENOTSUPP)
> +                       return -EOPNOTSUPP;
> +               status = nfs4_handle_exception(dst_server, status, &exception);
> +       } while (exception.retry);
> +
> +       return status;
> +}
> +
>  static loff_t _nfs42_proc_llseek(struct file *filep,
>                 struct nfs_lock_context *lock, loff_t offset, int whence)
>  {
> --

To test this and the server code I used the following patch:
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 317eab9..97d3937 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -156,7 +156,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
      struct file *src,
      struct file *dst,
      nfs4_stateid *src_stateid,
-     uint64_t *ret_count)
+     uint64_t *ret_count, uint64_t count)
 {
  struct nfs4_copy_state *copy;
  int status = NFS4_OK;
@@ -190,6 +190,24 @@ static int handle_async_copy(struct nfs42_copy_res *res,
  list_add_tail(&copy->copies, &server->ss_copies);
  spin_unlock(&server->nfs_client->cl_lock);

+ for (;;) {
+ struct nfs42_offload_status_res res = {
+ .osr_status = 0,
+ };
+
+ status = nfs42_proc_offload_status(dst, &copy->stateid, &res);
+ if (status || res.osr_status) {
+ printk("AGLO: status=%d osr_status=%d\n", status, res.osr_status);
+ break;
+ }
+ if (res.osr_count == count) {
+ printk("AGLO: received all the bytes=%lld\n", count);
+ break;
+ } else {
+ printk("AGLO: bytes=%lld going to sleep for 100ms\n", res.osr_count);
+ msleep(100);
+ }
+ }
  status = wait_for_completion_interruptible(&copy->completion);
  spin_lock(&server->nfs_client->cl_lock);
  list_del_init(&copy->copies);
@@ -310,7 +328,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,

  if (!res->synchronous) {
  status = handle_async_copy(res, server, src, dst,
- &args->src_stateid, &res->write_res.count);
+ &args->src_stateid, &res->write_res.count, args->count);
  if (status)
  return status;
  }

> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

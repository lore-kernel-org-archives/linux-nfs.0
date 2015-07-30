Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:58969 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132AbbG3Ou5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 10:50:57 -0400
Subject: Re: [PATCH for-4.3 02/15] IB: Modify ib_create_mr API
To: Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, target-devel@vger.kernel.org
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
 <1438241568-3685-3-git-send-email-sagig@mellanox.com>
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <55BA39D3.2030009@opengridcomputing.com>
Date: Thu, 30 Jul 2015 09:50:59 -0500
MIME-Version: 1.0
In-Reply-To: <1438241568-3685-3-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/30/2015 2:32 AM, Sagi Grimberg wrote:
> Use ib_alloc_mr with specific parameters.
> Change the existing callers.
>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> ---
>   drivers/infiniband/core/verbs.c          | 31 ++++++++++++++++++++------
>   drivers/infiniband/hw/mlx5/main.c        |  2 +-
>   drivers/infiniband/hw/mlx5/mlx5_ib.h     |  5 +++--
>   drivers/infiniband/hw/mlx5/mr.c          | 17 ++++++++++-----
>   drivers/infiniband/ulp/iser/iser_verbs.c |  6 ++----
>   drivers/infiniband/ulp/isert/ib_isert.c  |  6 +-----
>   include/rdma/ib_verbs.h                  | 37 +++++++++++++-------------------
>   7 files changed, 58 insertions(+), 46 deletions(-)
>
> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
> index 003bb62..2ac599b 100644
> --- a/drivers/infiniband/core/verbs.c
> +++ b/drivers/infiniband/core/verbs.c
> @@ -1272,15 +1272,32 @@ int ib_dereg_mr(struct ib_mr *mr)
>   }
>   EXPORT_SYMBOL(ib_dereg_mr);
>   
> -struct ib_mr *ib_create_mr(struct ib_pd *pd,
> -			   struct ib_mr_init_attr *mr_init_attr)
> +/**
> + * ib_alloc_mr() - Allocates a memory region
> + * @pd:            protection domain associated with the region
> + * @mr_type:       memory region type
> + * @max_num_sg:    maximum sg entries available for registration.
> + *
> + * Notes:
> + * Memory registeration page/sg lists must not exceed max_num_sg.
> + * For mr_type IB_MR_TYPE_MEM_REG, the total length cannot exceed
> + * max_num_sg * used_page_size.
> + *

Nit:  the above sounds like used_page_size is a variable.  Something 
like this might work?

"max_num_sg * the page size used for this sg list."


> + */
> +struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
> +			  enum ib_mr_type mr_type,
> +			  u32 max_num_sg)
>   {
>   	struct ib_mr *mr;
>   
> -	if (!pd->device->create_mr)
> -		return ERR_PTR(-ENOSYS);
> -
> -	mr = pd->device->create_mr(pd, mr_init_attr);
> +	if (pd->device->alloc_mr) {
> +		mr = pd->device->alloc_mr(pd, mr_type, max_num_sg);
> +	} else {
> +		if (mr_type != IB_MR_TYPE_MEM_REG ||
> +		    !pd->device->alloc_fast_reg_mr)
> +			return ERR_PTR(-ENOSYS);
> +		mr = pd->device->alloc_fast_reg_mr(pd, max_num_sg);
> +	}
>   
>   	if (!IS_ERR(mr)) {
>   		mr->device  = pd->device;
> @@ -1292,7 +1309,7 @@ struct ib_mr *ib_create_mr(struct ib_pd *pd,
>   
>   	return mr;
>   }
> -EXPORT_SYMBOL(ib_create_mr);
> +EXPORT_SYMBOL(ib_alloc_mr);
>   
>   struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
>   {
> diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
> index 46d1383..2c2a461 100644
> --- a/drivers/infiniband/hw/mlx5/main.c
> +++ b/drivers/infiniband/hw/mlx5/main.c
> @@ -1489,7 +1489,7 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
>   	dev->ib_dev.attach_mcast	= mlx5_ib_mcg_attach;
>   	dev->ib_dev.detach_mcast	= mlx5_ib_mcg_detach;
>   	dev->ib_dev.process_mad		= mlx5_ib_process_mad;
> -	dev->ib_dev.create_mr		= mlx5_ib_create_mr;
> +	dev->ib_dev.alloc_mr		= mlx5_ib_alloc_mr;
>   	dev->ib_dev.alloc_fast_reg_mr	= mlx5_ib_alloc_fast_reg_mr;
>   	dev->ib_dev.alloc_fast_reg_page_list = mlx5_ib_alloc_fast_reg_page_list;
>   	dev->ib_dev.free_fast_reg_page_list  = mlx5_ib_free_fast_reg_page_list;
> diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
> index 537f42e..3030abe 100644
> --- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
> +++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
> @@ -572,8 +572,9 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
>   int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index,
>   		       int npages, int zap);
>   int mlx5_ib_dereg_mr(struct ib_mr *ibmr);
> -struct ib_mr *mlx5_ib_create_mr(struct ib_pd *pd,
> -				struct ib_mr_init_attr *mr_init_attr);
> +struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
> +			       enum ib_mr_type mr_type,
> +			       u32 max_num_sg);
>   struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
>   					int max_page_list_len);
>   struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
> diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
> index 03cf74e..b0b68bb 100644
> --- a/drivers/infiniband/hw/mlx5/mr.c
> +++ b/drivers/infiniband/hw/mlx5/mr.c
> @@ -1246,14 +1246,15 @@ int mlx5_ib_dereg_mr(struct ib_mr *ibmr)
>   	return 0;
>   }
>   
> -struct ib_mr *mlx5_ib_create_mr(struct ib_pd *pd,
> -				struct ib_mr_init_attr *mr_init_attr)
> +struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
> +			       enum ib_mr_type mr_type,
> +			       u32 max_num_sg)
>   {
>   	struct mlx5_ib_dev *dev = to_mdev(pd->device);
>   	struct mlx5_create_mkey_mbox_in *in;
>   	struct mlx5_ib_mr *mr;
>   	int access_mode, err;
> -	int ndescs = roundup(mr_init_attr->max_reg_descriptors, 4);
> +	int ndescs = roundup(max_num_sg, 4);
>   
>   	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
>   	if (!mr)
> @@ -1269,9 +1270,11 @@ struct ib_mr *mlx5_ib_create_mr(struct ib_pd *pd,
>   	in->seg.xlt_oct_size = cpu_to_be32(ndescs);
>   	in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
>   	in->seg.flags_pd = cpu_to_be32(to_mpd(pd)->pdn);
> -	access_mode = MLX5_ACCESS_MODE_MTT;
>   
> -	if (mr_init_attr->flags & IB_MR_SIGNATURE_EN) {
> +	if (mr_type == IB_MR_TYPE_MEM_REG) {
> +		access_mode = MLX5_ACCESS_MODE_MTT;
> +		in->seg.log2_page_size = PAGE_SHIFT;
> +	} else if (mr_type == IB_MR_TYPE_SIGNATURE) {
>   		u32 psv_index[2];
>   
>   		in->seg.flags_pd = cpu_to_be32(be32_to_cpu(in->seg.flags_pd) |
> @@ -1297,6 +1300,10 @@ struct ib_mr *mlx5_ib_create_mr(struct ib_pd *pd,
>   		mr->sig->sig_err_exists = false;
>   		/* Next UMR, Arm SIGERR */
>   		++mr->sig->sigerr_count;
> +	} else {
> +		mlx5_ib_warn(dev, "Invalid mr type %d\n", mr_type);
> +		err = -EINVAL;
> +		goto err_free_in;
>   	}
>   
>   	in->seg.flags = MLX5_PERM_UMR_EN | access_mode;
> diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
> index 255321c..9bef5a7 100644
> --- a/drivers/infiniband/ulp/iser/iser_verbs.c
> +++ b/drivers/infiniband/ulp/iser/iser_verbs.c
> @@ -284,9 +284,7 @@ iser_alloc_pi_ctx(struct ib_device *ib_device, struct ib_pd *pd,
>   		  struct fast_reg_descriptor *desc)
>   {
>   	struct iser_pi_context *pi_ctx = NULL;
> -	struct ib_mr_init_attr mr_init_attr = {.max_reg_descriptors = 2,
> -					       .flags = IB_MR_SIGNATURE_EN};
> -	int ret = 0;
> +	int ret;
>   
>   	desc->pi_ctx = kzalloc(sizeof(*desc->pi_ctx), GFP_KERNEL);
>   	if (!desc->pi_ctx)
> @@ -309,7 +307,7 @@ iser_alloc_pi_ctx(struct ib_device *ib_device, struct ib_pd *pd,
>   	}
>   	desc->reg_indicators |= ISER_PROT_KEY_VALID;
>   
> -	pi_ctx->sig_mr = ib_create_mr(pd, &mr_init_attr);
> +	pi_ctx->sig_mr = ib_alloc_mr(pd, IB_MR_TYPE_SIGNATURE, 2);
>   	if (IS_ERR(pi_ctx->sig_mr)) {
>   		ret = PTR_ERR(pi_ctx->sig_mr);
>   		goto sig_mr_failure;
> diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
> index 559e6be..23a793a 100644
> --- a/drivers/infiniband/ulp/isert/ib_isert.c
> +++ b/drivers/infiniband/ulp/isert/ib_isert.c
> @@ -497,7 +497,6 @@ isert_create_pi_ctx(struct fast_reg_descriptor *desc,
>   		    struct ib_device *device,
>   		    struct ib_pd *pd)
>   {
> -	struct ib_mr_init_attr mr_init_attr;
>   	struct pi_context *pi_ctx;
>   	int ret;
>   
> @@ -525,10 +524,7 @@ isert_create_pi_ctx(struct fast_reg_descriptor *desc,
>   	}
>   	desc->ind |= ISERT_PROT_KEY_VALID;
>   
> -	memset(&mr_init_attr, 0, sizeof(mr_init_attr));
> -	mr_init_attr.max_reg_descriptors = 2;
> -	mr_init_attr.flags |= IB_MR_SIGNATURE_EN;
> -	pi_ctx->sig_mr = ib_create_mr(pd, &mr_init_attr);
> +	pi_ctx->sig_mr = ib_alloc_mr(pd, IB_MR_TYPE_SIGNATURE, 2);
>   	if (IS_ERR(pi_ctx->sig_mr)) {
>   		isert_err("Failed to allocate signature enabled mr err=%ld\n",
>   			  PTR_ERR(pi_ctx->sig_mr));
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index a534ee5..110044d 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -556,20 +556,18 @@ __attribute_const__ int ib_rate_to_mult(enum ib_rate rate);
>    */
>   __attribute_const__ int ib_rate_to_mbps(enum ib_rate rate);
>   
> -enum ib_mr_create_flags {
> -	IB_MR_SIGNATURE_EN = 1,
> -};
>   
>   /**
> - * ib_mr_init_attr - Memory region init attributes passed to routine
> - *     ib_create_mr.
> - * @max_reg_descriptors: max number of registration descriptors that
> - *     may be used with registration work requests.
> - * @flags: MR creation flags bit mask.
> + * enum ib_mr_type - memory region type
> + * @IB_MR_TYPE_MEM_REG:       memory region that is used for
> + *                            normal registration
> + * @IB_MR_TYPE_SIGNATURE:     memory region that is used for
> + *                            signature operations (data-integrity
> + *                            capable regions)
>    */
> -struct ib_mr_init_attr {
> -	int	    max_reg_descriptors;
> -	u32	    flags;
> +enum ib_mr_type {
> +	IB_MR_TYPE_MEM_REG,
> +	IB_MR_TYPE_SIGNATURE,
>   };
>   
>   /**
> @@ -1670,8 +1668,9 @@ struct ib_device {
>   	int                        (*query_mr)(struct ib_mr *mr,
>   					       struct ib_mr_attr *mr_attr);
>   	int                        (*dereg_mr)(struct ib_mr *mr);
> -	struct ib_mr *		   (*create_mr)(struct ib_pd *pd,
> -						struct ib_mr_init_attr *mr_init_attr);
> +	struct ib_mr *		   (*alloc_mr)(struct ib_pd *pd,
> +					       enum ib_mr_type mr_type,
> +					       u32 max_num_sg);
>   	struct ib_mr *		   (*alloc_fast_reg_mr)(struct ib_pd *pd,
>   					       int max_page_list_len);
>   	struct ib_fast_reg_page_list * (*alloc_fast_reg_page_list)(struct ib_device *device,
> @@ -2815,15 +2814,9 @@ int ib_query_mr(struct ib_mr *mr, struct ib_mr_attr *mr_attr);
>    */
>   int ib_dereg_mr(struct ib_mr *mr);
>   
> -
> -/**
> - * ib_create_mr - Allocates a memory region that may be used for
> - *     signature handover operations.
> - * @pd: The protection domain associated with the region.
> - * @mr_init_attr: memory region init attributes.
> - */
> -struct ib_mr *ib_create_mr(struct ib_pd *pd,
> -			   struct ib_mr_init_attr *mr_init_attr);
> +struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
> +			  enum ib_mr_type mr_type,
> +			  u32 max_num_sg);
>   
>   /**
>    * ib_alloc_fast_reg_mr - Allocates memory region usable with the


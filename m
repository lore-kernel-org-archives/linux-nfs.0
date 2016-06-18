Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21942 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbcFRUI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Jun 2016 16:08:28 -0400
Content-Type: multipart/mixed; boundary="Apple-Mail=_BF26E157-A818-4260-9FED-DF0B680B26A9"
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160618105650.GD5408@leon.nu>
Date: Sat, 18 Jun 2016 16:08:20 -0400
Cc: Sagi Grimberg <sagigrim@gmail.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net> <20160615031525.14794.69066.stgit@manet.1015granger.net> <20160615042849.GR5408@leon.nu> <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com> <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com> <652EBA09-2978-414C-8606-38A96C63365A@oracle.com> <20160617092018.GZ5408@leon.nu> <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com> <20160618105650.GD5408@leon.nu>
To: leon@kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_BF26E157-A818-4260-9FED-DF0B680B26A9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Jun 18, 2016, at 6:56 AM, Leon Romanovsky <leon@kernel.org> wrote:
>=20
> On Fri, Jun 17, 2016 at 03:55:56PM -0400, Chuck Lever wrote:
>>=20
>>> On Jun 17, 2016, at 5:20 AM, Leon Romanovsky <leon@kernel.org> =
wrote:
>>>=20
>>> On Thu, Jun 16, 2016 at 05:58:29PM -0400, Chuck Lever wrote:
>>>>=20
>>>> I think the patch description justifies the choice of
>>>> solution, but does not describe the original issue at
>>>> all. The original issue had nothing to do with cacheline
>>>> alignment.
>>>=20
>>> I disagree, kmalloc with supplied flags will return contiguous =
memory
>>> which is enough for dma_map_single. It is cache line alignment.
>>=20
>> The reason I find this hard to believe is that there is
>> no end alignment guarantee at all in this code, but it
>> works without issue when SLUB debugging is not enabled.
>>=20
>> xprtrdma allocates 256 elements in this array on x86.
>> The code makes the array start on an 0x40 byte boundary.
>> I'm pretty sure that means the end of that array will
>> also be on at least an 0x40 byte boundary, and thus
>> aligned to the DMA cacheline, whether or not SLUB
>> debugging is enabled.
>>=20
>> Notice that in the current code, if the consumer requests
>> an odd number of SGs, that array can't possibly end on
>> an alignment boundary. But we've never had a complaint.
>>=20
>> SLUB debugging changes the alignment of lots of things,
>> but mlx4_alloc_priv_pages is the only breakage that has
>> been reported.
>=20
> I think it is related to custom logic which is in this function only.
> I posted grep output earlier to emphasize it.
>=20
> For example adds 2K region after the actual data and it will ensure
> alignment.
>=20
>>=20
>> DMA-API.txt says:
>>=20
>>> [T]he mapped region must begin exactly on a cache line
>>> boundary and end exactly on one (to prevent two separately
>>> mapped regions from sharing a single cache line)
>>=20
>> The way I read this, cacheline alignment shouldn't be
>> an issue at all, as long as DMA cachelines aren't
>> shared between mappings.
>>=20
>> If I simply increase the memory allocation size a little
>> and ensure the end of the mapping is aligned, that should
>> be enough to prevent DMA cacheline sharing with another
>> memory allocation on the same page. But I still see Local
>> Protection Errors when SLUB debugging is enabled, on my
>> system (with patches to allocate more pages per MR).
>>=20
>> I'm not convinced this has anything to do with DMA
>> cacheline alignment. The reason your patch fixes this
>> issue is because it keeps the entire array on one page.
>=20
> If you don't mind, we can do an experiment.
> Let's add padding which will prevent alignment issue and
> for sure will cross the page boundary.
>=20
> diff --git a/drivers/infiniband/hw/mlx4/mr.c
> b/drivers/infiniband/hw/mlx4/mr.c
> index 6312721..41e277e 100644
> --- a/drivers/infiniband/hw/mlx4/mr.c
> +++ b/drivers/infiniband/hw/mlx4/mr.c
> @@ -280,8 +280,10 @@ mlx4_alloc_priv_pages(struct ib_device *device,
>        int size =3D max_pages * sizeof(u64);
> 	int add_size;
> 	int ret;
> -
> +/*
>        add_size =3D max_t(int, MLX4_MR_PAGES_ALIGN - =
ARCH_KMALLOC_MINALIGN, 0);
> +*/
> +       add_size =3D 2048;
>=20
>        mr->pages_alloc =3D kzalloc(size + add_size, GFP_KERNEL);
> 	if (!mr->pages_alloc)

Hi Leon-

I created a different patch, see attachment. It aligns
the start _and_ end of the DMA mapped region, places
large arrays so they encounter a page boundary, and
leaves slack space around each array so there is no
possibility of a shared DMA cacheline or other activity
in that memory.

I am able to reproduce the Local Protection Errors with
this patch applied and SLUB debugging disabled.


--
Chuck Lever


--Apple-Mail=_BF26E157-A818-4260-9FED-DF0B680B26A9
Content-Disposition: attachment;
	filename=fix-mlx4-alloc-priv-pages.diff
Content-Type: application/octet-stream;
	name="fix-mlx4-alloc-priv-pages.diff"
Content-Transfer-Encoding: 7bit

mlx4-ib: Fix mlx4_alloc_priv_pages()

From: Chuck Lever <chuck.lever@oracle.com>
Date: 2016-06-17 13:49:27 -0400

Place large mr->pages arrays on a page boundary to explore the
problem.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    3 ++-
 drivers/infiniband/hw/mlx4/mr.c      |   31 +++++++++++++++++--------------
 2 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 6c5ac5d..163ff90 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -139,7 +139,8 @@ struct mlx4_ib_mr {
 	u32			max_pages;
 	struct mlx4_mr		mmr;
 	struct ib_umem	       *umem;
-	void			*pages_alloc;
+	unsigned long		pages_alloc;
+	size_t			page_map_size;
 };
 
 struct mlx4_ib_mw {
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 6312721..753390e 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -277,20 +277,26 @@ mlx4_alloc_priv_pages(struct ib_device *device,
 		      struct mlx4_ib_mr *mr,
 		      int max_pages)
 {
-	int size = max_pages * sizeof(u64);
-	int add_size;
 	int ret;
 
-	add_size = max_t(int, MLX4_MR_PAGES_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
+	/* Round mapping size up to ensure DMA cacheline alignment,
+	 * and cache the size to avoid mult/div in fast path */
+	mr->page_map_size = roundup(max_pages * sizeof(u64),
+				    MLX4_MR_PAGES_ALIGN);
 
-	mr->pages_alloc = kzalloc(size + add_size, GFP_KERNEL);
+	/* Allocate two pages to ensure there is a page boundary
+	 * in the array, and unused slack space around the array */
+	mr->pages_alloc = __get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
 	if (!mr->pages_alloc)
 		return -ENOMEM;
 
-	mr->pages = PTR_ALIGN(mr->pages_alloc, MLX4_MR_PAGES_ALIGN);
+	/* Place the array near the page boundary, aligned with
+	 * MLX4_MR_PAGES_ALIGN (assuming 4KB pages) */
+	mr->pages = (__be64 *)mr->pages_alloc;
+	mr->pages += (MLX4_MR_PAGES_ALIGN * 48) / sizeof(__be64);
 
 	mr->page_map = dma_map_single(device->dma_device, mr->pages,
-				      size, DMA_TO_DEVICE);
+				      mr->page_map_size, DMA_TO_DEVICE);
 
 	if (dma_mapping_error(device->dma_device, mr->page_map)) {
 		ret = -ENOMEM;
@@ -299,7 +305,7 @@ mlx4_alloc_priv_pages(struct ib_device *device,
 
 	return 0;
 err:
-	kfree(mr->pages_alloc);
+	free_pages(mr->pages_alloc, 1);
 
 	return ret;
 }
@@ -309,11 +315,10 @@ mlx4_free_priv_pages(struct mlx4_ib_mr *mr)
 {
 	if (mr->pages) {
 		struct ib_device *device = mr->ibmr.device;
-		int size = mr->max_pages * sizeof(u64);
 
 		dma_unmap_single(device->dma_device, mr->page_map,
-				 size, DMA_TO_DEVICE);
-		kfree(mr->pages_alloc);
+				 mr->page_map_size, DMA_TO_DEVICE);
+		free_pages(mr->pages_alloc, 1);
 		mr->pages = NULL;
 	}
 }
@@ -537,14 +542,12 @@ int mlx4_ib_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg, int sg_nents,
 	mr->npages = 0;
 
 	ib_dma_sync_single_for_cpu(ibmr->device, mr->page_map,
-				   sizeof(u64) * mr->max_pages,
-				   DMA_TO_DEVICE);
+				   mr->page_map_size, DMA_TO_DEVICE);
 
 	rc = ib_sg_to_pages(ibmr, sg, sg_nents, sg_offset, mlx4_set_page);
 
 	ib_dma_sync_single_for_device(ibmr->device, mr->page_map,
-				      sizeof(u64) * mr->max_pages,
-				      DMA_TO_DEVICE);
+				      mr->page_map_size, DMA_TO_DEVICE);
 
 	return rc;
 }

--Apple-Mail=_BF26E157-A818-4260-9FED-DF0B680B26A9
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii



--Apple-Mail=_BF26E157-A818-4260-9FED-DF0B680B26A9--

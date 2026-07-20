Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7461B3D3337;
	Mon, 20 Jul 2026 09:15:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784538910; cv=none; b=nUkmG2oD//qZ7rBTPKp2GzE3oQM/GMvUtnt/BK91brkGrllBMb8SYphOKnc+JdiUVqQE7XYCJYbpqLY1r/C3CL/Ex3uUIht/RNOlFozD5RFRM8OcnzLs/C+Q/x/YvLWvcghqV8SKc9h2opUYyeu1r2vhUH2NctSj7I3vzQ2kDZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784538910; c=relaxed/simple;
	bh=H3Gadch1gGzuSoO/LFWAu3JxEx26lGt3Hcr1nGDhEUc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kQTKZiwO6G9lwmEoVGruCDp9bJiGWo3rT/pisQ9PGV+kWG7ApxGQWZG+HFcHNzBp0HQvTihHzc42me8OCeo8eeNXdPYEW0scaE0ESusFIReCgmehrs9lcGT2iZYStpA7QlzjC36H0F8MG2ZqMGQ23HIyarLIYzdr5qWDJM3t/s8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id BA27468BEB; Mon, 20 Jul 2026 11:15:05 +0200 (CEST)
Date: Mon, 20 Jul 2026 11:15:05 +0200
From: Christoph Hellwig <hch@lst.de>
To: Pranjal Shrivastava <praan@google.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 3/5] nfs: Introduce nfs_release_request_list helper
Message-ID: <20260720091505.GC24298@lst.de>
References: <20260715143540.3597616-1-praan@google.com> <20260715143540.3597616-4-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260715143540.3597616-4-praan@google.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Jul 15, 2026 at 02:35:38PM +0000, Pranjal Shrivastava wrote:
> Introduce a centralized helper, nfs_release_request_list, to handle
> the bulk release of nfs_page requests from a list.
> 
> This serves as a preparatory step for two upcoming improvements:
> 
>    1. Pin-Aware Cleanup: As we migrate to iov_iter_extract_* API,
>       requests will hold pins (GUP) instead of standard references. The
>       helper ensures that the correct unpinning logic gets applied
>       consistently across all requests in a list.
> 
>    2. Folio Support: In subsequent patches where nfs_page structures
>       will cover multi-page folios, this helper provides a clean
>       infrastructure to unlock these larger units of I/O in bulk during
>       completion, similat to the pattern in bio_release_pages.
> 
> Additionally, refactor nfs_read_sync_pgio_error() to utilize this new
> helper.
> 
> Signed-off-by: Pranjal Shrivastava <praan@google.com>
> ---
>  fs/nfs/direct.c          |  8 +-------
>  fs/nfs/pagelist.c        | 18 ++++++++++++++++++
>  include/linux/nfs_page.h |  4 ++--
>  3 files changed, 21 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 19792a38c924..96995736fac2 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -314,13 +314,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
>  
>  static void nfs_read_sync_pgio_error(struct list_head *head, int error)
>  {
> -	struct nfs_page *req;
> -
> -	while (!list_empty(head)) {
> -		req = nfs_list_entry(head->next);
> -		nfs_list_remove_request(req);
> -		nfs_release_request(req);
> -	}
> +	nfs_release_request_list(head);
>  }
>  
>  static void nfs_direct_pgio_init(struct nfs_pgio_header *hdr)
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 7d51e10fe97a..569bac4faff7 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -622,6 +622,24 @@ void nfs_release_request(struct nfs_page *req)
>  }
>  EXPORT_SYMBOL_GPL(nfs_release_request);
>  
> +/*
> + * nfs_release_request_list - Release a list of NFS read/write requests
> + * @head: list of requests to release
> + *
> + * Removes each request from the list and drops it's refcount.
> + */
> +void nfs_release_request_list(struct list_head *head)
> +{
> +	struct nfs_page *req;
> +
> +	while (!list_empty(head)) {
> +		req = nfs_list_entry(head->next);

req could/should be local here.  Or you switch to list_first_or_null,
which some folks prefer.

> +extern void nfs_release_request(struct nfs_page *req);
> +extern void nfs_release_request_list(struct list_head *head);

Please drop the superflous externs for new code.


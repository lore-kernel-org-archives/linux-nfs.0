Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab2AZVZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 16:25:55 -0500
Date: Thu, 26 Jan 2012 16:25:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Clean up the test_stateid function
Message-ID: <20120126212554.GE700@fieldses.org>
References: <1327510095-26125-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327510095-26125-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 11:48:15AM -0500, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> When I initially wrote it, I didn't understand how lists worked so I
> wrote something that didn't use them.  I think making a list of stateids
> to test is a more straightforward implementation, especially compared to
> especially compared to decoding stateids while simultaneously encoding
> a reply to the client.

Thanks, yes, I'll be much happier with something like this.  The only
thing I'm worried about:

>  static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  {
>  	/* We want more bytes than seem to be available.
> @@ -1385,31 +1369,36 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
>  static __be32
>  nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_stateid *test_stateid)
>  {
> -	unsigned int nbytes;
> -	stateid_t si;
>  	int i;
> -	__be32 *p;
> -	__be32 status;
> +	__be32 *p, status;
> +	struct nfsd4_test_stateid_id *stateid;
>  
>  	READ_BUF(4);
>  	test_stateid->ts_num_ids = ntohl(*p++);
>  
> -	nbytes = test_stateid->ts_num_ids * sizeof(stateid_t);
> -	if (nbytes > (u32)((char *)argp->end - (char *)argp->p))
> -		goto xdr_error;
> -
> -	test_stateid->ts_saved_args = argp;
> -	save_buf(argp, &test_stateid->ts_savedp);
> +	INIT_LIST_HEAD(&test_stateid->ts_stateid_list);
>  
>  	for (i = 0; i < test_stateid->ts_num_ids; i++) {
> -		status = nfsd4_decode_stateid(argp, &si);
> +		stateid = kmalloc(sizeof(struct nfsd4_test_stateid_id), GFP_KERNEL);

Hm, are you sure this will always get freed in all cases?

Off the top of my head: the compound gets decode in one fell swoop.  The
we process and encode each op one at a time.  So, for example, if we
fail later in the decoding, or if processing fails on an earlier op than
this one, then we're not going to hit the free in the encoder:

>  nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
>  			  struct nfsd4_test_stateid *test_stateid)
>  {
...
> +	list_for_each_entry_safe(stateid, next, &test_stateid->ts_stateid_list, ts_id_list) {
> +		*p++ = htonl(stateid->ts_id_status);
> +		list_del(&stateid->ts_id_list);
> +		kfree(stateid);

Hence the defer_free/release_compoundargs stuff.  If you grep through
nfs4xdr.c for defer_free I think you'll see how it works.

--b.

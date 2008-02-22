From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] NFS: clean up short packet handling for NFSv3 readdir
Date: Fri, 22 Feb 2008 16:11:12 -0500
Message-ID: <47BF3A70.4040409@oracle.com>
References: <1203709801-20055-1-git-send-email-jlayton@redhat.com>	<1203709801-20055-2-git-send-email-jlayton@redhat.com>
	<1203709801-20055-3-git-send-email-jlayton@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070405030801020000020709"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1203709801-20055-3-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070405030801020000020709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff-

For NFSv3, is the READDIRPLUS decoder affected as well?

Jeff Layton wrote:
> Currently, the NFS readdir decoders have a workaround for buggy servers
> that send an empty readdir response with the EOF bit unset. If the
> server sends a malformed response in some cases, this workaround kicks
> in and just returns an empty response rather than returning a proper
> error to the caller.
> 
> This patch does 3 things:
> 
> 1) have malformed responses with no entries return error (-EIO)
> 
> 2) preserve existing workaround for servers that send empty
>    responses with the EOF marker unset.
> 
> 3) Add some comments to clarify the logic in nfs3_xdr_readdirres().
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/nfs3xdr.c |   37 ++++++++++++++++++++++++++++---------
>  1 files changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 3917e2f..fb03048 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -508,7 +508,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
>  	struct page **page;
>  	size_t hdrlen;
>  	u32 len, recvd, pglen;
> -	int status, nr;
> +	int status, nr = 0;
>  	__be32 *entry, *end, *kaddr;
>  
>  	status = ntohl(*p++);
> @@ -542,7 +542,12 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
>  	kaddr = p = kmap_atomic(*page, KM_USER0);
>  	end = (__be32 *)((char *)p + pglen);
>  	entry = p;
> -	for (nr = 0; *p++; nr++) {
> +
> +	/* Make sure the packet actually has a value_follows and EOF entry */
> +	if ((entry + 1) > end)
> +		goto short_pkt;
> +
> +	for (; *p++; nr++) {
>  		if (p + 3 > end)
>  			goto short_pkt;
>  		p += 2;				/* inode # */
> @@ -581,18 +586,32 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
>  			goto short_pkt;
>  		entry = p;
>  	}
> -	if (!nr && (entry[0] != 0 || entry[1] == 0))
> -		goto short_pkt;
> +
> +	/*
> +	 * Apparently some server sends responses that are a valid size, but
> +	 * contain no entries, and have value_follows==0 and EOF==0. For
> +	 * those, just set the EOF marker.
> +	 */
> +	if (!nr && entry[1] == 0) {
> +		dprintk("NFS: readdir reply truncated!\n");
> +		entry[1] = 1;
> +	}
>   out:
>  	kunmap_atomic(kaddr, KM_USER0);
>  	return nr;
>   short_pkt:
> +	/*
> +	 * When we get a short packet there are 2 possibilities. We can
> +	 * return an error, or fix up the response to look like a valid
> +	 * response and return what we have so far. If there are no
> +	 * entries and the packet was short, then return -EIO. If there
> +	 * are valid entries in the response, return them and pretend that
> +	 * the call was successful, but incomplete. The caller can retry the
> +	 * readdir starting at the last cookie.
> +	 */
>  	entry[0] = entry[1] = 0;
> -	/* truncate listing ? */
> -	if (!nr) {
> -		dprintk("NFS: readdir reply truncated!\n");
> -		entry[1] = 1;
> -	}
> +	if (!nr)
> +		nr = -errno_NFSERR_IO;
>  	goto out;
>  err_unmap:
>  	nr = -errno_NFSERR_IO;

--------------070405030801020000020709
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070405030801020000020709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------070405030801020000020709--

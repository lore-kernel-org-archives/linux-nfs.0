Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33529 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756004Ab0KNPnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 10:43:37 -0500
Message-ID: <4CE003A6.2000606@panasas.com>
Date: Sun, 14 Nov 2010 17:43:34 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, NFSv4 <nfsv4@ietf.org>
Subject: Re: [PATCH 16/22] pnfs-submit: rewrite of layout state handling and
 cb_layoutrecall
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com> <1289551724-18575-17-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-17-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-12 10:48, Fred Isaman wrote:
> +int
> +pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
> +			      struct nfs4_state *open_state)
>  {
> +	int status = 0;
> +
>  	dprintk("--> %s\n", __func__);
>  	spin_lock(&lo->inode->i_lock);
> -	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
> +	if (lo->plh_block_lgets ||
> +	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
> +		/* We avoid -EAGAIN, as that has special meaning to
> +		 * some callers.
> +		 */
> +		status = -NFS4ERR_LAYOUTTRYLATER;
> +	} else if (list_empty(&lo->segs)) {
>  		int seq;
>  
>  		do {
> @@ -494,12 +514,11 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>  			memcpy(dst->data, open_state->stateid.data,
>  			       sizeof(open_state->stateid.data));
>  		} while (read_seqretry(&open_state->seqlock, seq));

Using the open stateid after forgetting the layout could be a protocol bug,
or at least it falls into undefined territories.

The RFC says:

   The loga_stateid field specifies a valid stateid.  If a layout is not
   currently held by the client, the loga_stateid field represents a
   stateid reflecting the correspondingly valid open, byte-range lock,
   or delegation stateid.  Once a layout is held on the file by the
   client, the loga_stateid field MUST be a stateid as returned from a
   previous LAYOUTGET or LAYOUTRETURN operation or provided by a
   CB_LAYOUTRECALL operation (see Section 12.5.3).

So the question is does the text above refer to the client view of the state or to
the server's view.
In other words, with the forgetful client model, when the client unilaterally forgets
the layout without letting the server know about it (no LAYOUTRETURN was sent),
does it mean "a layout is not currently held by the client"?

The server will see a LAYOUTGET with an open/lock/deleg stateid in this case
while it still thinks that the client is holding a layout.
Since this could normally happen if the client sends multiple LAYOUTGETs in
parallel before it received any layout stateid the server should allow it
within the VALID_SEQID_RANGE constraints (see 12.5.5.2.1.4, although it is
not explicitly called out there), otherwise, it seems like the server is supposed
to return NFS4ERR_OLD_STATEID.

Strictly reading the spec, the client should use the most recent layout stateid
even in the forgetful model, until it gets a LAYOUTRETURN reply with lrs_present==false
or until it replies NFS4ERR_NOMATCHING_LAYOUT to CB_LAYOUTRECALL with
clora_iomode==LAYOUTIOMODE4_ANY or other values where the client never dropped
a layout (did I say recently how much I hate the forgetful model which introduces
more corner cases rather than simplifying the protocol as it was supposed to do? ;-)

Benny

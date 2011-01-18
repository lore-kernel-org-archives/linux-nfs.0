From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] decode_cb_op_status fix
Date: Tue, 18 Jan 2011 16:57:44 -0500
Message-ID: <20110118215744.GD10903@fieldses.org>
References: <4D2EC4AC.9090205@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59833 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923Ab1ARV5r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 16:57:47 -0500
In-Reply-To: <4D2EC4AC.9090205@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 13, 2011 at 11:23:56AM +0200, Benny Halevy wrote:
> Chuck, it looks like the following patch introduced a couple in
> handling of the operation status.
> 
> 85a5648 NFSD: Update XDR decoders in NFSv4 callback client
> 
> The first patch in this series fixes the bugs and the second
> reintroduces the handling of nfserr into decode_cb_op_status
> as it used to be in decode_cb_op_hdr, since I think it's simpler
> with respect to the current usage (vs. theoretical generic use of
> decode_cb_op_status to decode the status and return it in an output var).

Looks OK to me, thanks.

--b.

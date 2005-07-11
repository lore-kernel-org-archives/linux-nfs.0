From: Nick Wilson <njw@osdl.org>
Subject: Re: [PATCH 2/3]: NFS: use atomic bitops to manipulate flags in nfsi->flags
Date: Mon, 11 Jul 2005 13:08:30 -0700
Message-ID: <20050711200830.GA5034@njw.pdx.osdl.net>
References: <482A3FA0050D21419C269D13989C611308539D86@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
	nfs@lists.sourceforge.net, Daniel McNeil <daniel@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds4XH-00047R-21
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 13:05:51 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds4XG-0005yL-Ly
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 13:05:51 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539D86@lavender-fe.eng.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sat, Jul 09, 2005 at 08:33:06AM -0700, Lever, Charles wrote:
>  Introduce atomic bitops to manipulate the bits in the nfs_inode structure's
>  "flags" field.
> 
>  Using bitops means we can use a generic wait_on_bit call instead of an ad
>  hoc locking scheme in fs/nfs/inode.c, so we can remove the "nfs_i_wait"
>  field from nfs_inode at the same time.
> 
>  The other new flags field will continue to use bitmask and logic AND and
>  OR.  This permits several flags to be set at the same time efficiently.
>  The following patch adds a spin lock to protect these flags, and this spin
>  lock will later cover other fields in the nfs_inode structure, amortizing
>  the cost of using this type of serialization.

Is there some place to document exactly which fields are being protected by
the spinlock?

[ ... ]
>  /*
>   * Wait for the inode to get unlocked.
> - * (Used for NFS_INO_LOCKED and NFS_INO_REVALIDATING).
>   */
> -static int
> -nfs_wait_on_inode(struct inode *inode, int flag)
> +static int nfs_wait_on_inode(struct inode *inode)
>  {
>  	struct rpc_clnt	*clnt = NFS_CLIENT(inode);
>  	struct nfs_inode *nfsi = NFS_I(inode);
> -
> +	sigset_t oldmask;
>  	int error;
> -	if (!(NFS_FLAGS(inode) & flag))
> -		return 0;
> +
>  	atomic_inc(&inode->i_count);
> -	error = nfs_wait_event(clnt, nfsi->nfs_i_wait,
> -				!(NFS_FLAGS(inode) & flag));
> +	rpc_clnt_sigmask(clnt, &oldmask);
> +	error = wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
> +					nfs_wait_schedule, TASK_INTERRUPTIBLE);

                                                                ^^^^^^^^^^^^^
Shouldn't this depend on whether the client mounted with intr?

Nick Wilson


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: writeable file with no mnt_want_write()
Date: Tue, 08 Jul 2008 11:40:52 +0300
Message-ID: <48732814.2050004@panasas.com>
References: <486CC466.6060504@panasas.com> <20080703203601.GE30918@fieldses.org> <486E18C3.1040703@panasas.com> <20080707190517.GF14291@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:8134 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750823AbYGHIlQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2008 04:41:16 -0400
In-Reply-To: <20080707190517.GF14291@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 07, 2008, 22:05 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, Jul 04, 2008 at 03:34:11PM +0300, Benny Halevy wrote:
>> On Jul. 03, 2008, 23:36 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> We're just trying to enforce rfc 3530 14.2.19:
>> OK. I see.
>> Thanks for explaining!
>> It is a bit mind boggling, maybe adding some comments explaining
>> why the bitmap is needed would help...
> 
> Where do you think you would have looked for a comment?  I figured just
> before the helper functions here was one obvious place.

Yup. Either here, or closer to (nfsd's) struct nfs4_stateid's definition
where st_{access,deny}_bmap are defined.

Benny

> 
> --b.
> 
> commit 4f83aa302f8f8b42397c6d3703d670f0588c03ec
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Mon Jul 7 15:02:02 2008 -0400
> 
>     nfsd: document open share bit tracking
>     
>     It's not immediately obvious from the code why we're doing this.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>     Cc: Benny Halevy <bhalevy@panasas.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index eca8aaa..c29b6ed 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1173,6 +1173,24 @@ static inline int deny_valid(u32 x)
>  	return x <= NFS4_SHARE_DENY_BOTH;
>  }
>  
> +/*
> + * We store the NONE, READ, WRITE, and BOTH bits separately in the
> + * st_{access,deny}_bmap field of the stateid, in order to track not
> + * only what share bits are currently in force, but also what
> + * combinations of share bits previous opens have used.  This allows us
> + * to enforce the recommendation of rfc 3530 14.2.19 that the server
> + * return an error if the client attempt to downgrade to a combination
> + * of share bits not explicable by closing some of its previous opens.
> + *
> + * XXX: This enforcement is actually incomplete, since we don't keep
> + * track of access/deny bit combinations; so, e.g., we allow:
> + *
> + *	OPEN allow read, deny write
> + *	OPEN allow both, deny none
> + *	DOWNGRADE allow read, deny none
> + *
> + * which we should reject.
> + */
>  static void
>  set_access(unsigned int *access, unsigned long bmap) {
>  	int i;


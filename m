Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab1AQPVA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jan 2011 10:21:00 -0500
Date: Mon, 17 Jan 2011 10:20:48 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: break lease on unlink, link, and rename
Message-ID: <20110117152048.GA4796@pad.home.fieldses.org>
References: <1294853809-10732-1-git-send-email-bfields@redhat.com>
 <1294853809-10732-3-git-send-email-bfields@redhat.com>
 <4D3007A1.6030405@cn.fujitsu.com>
 <20110114193327.GA16942@fieldses.org>
 <4D33A4BC.4000103@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D33A4BC.4000103@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 17, 2011 at 10:09:00AM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields :
> > On Fri, Jan 14, 2011 at 04:21:53PM +0800, Mi Jinlong wrote:
> >>
> >> J. Bruce Fields:
> >>> Any change to any of the links pointing to an entry should also break
> >>> delegations.
> >>>
> >>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >>> ---
> >>>  fs/nfsd/vfs.c |   27 +++++++++++++++++++++++----
> >>>  1 files changed, 23 insertions(+), 4 deletions(-)
> >>>
> >>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> >>> index 839ed88..f31321a 100644
> >>> --- a/fs/nfsd/vfs.c
> >>> +++ b/fs/nfsd/vfs.c
> >>> @@ -272,6 +272,13 @@ out:
> >>>  	return err;
> >>>  }
> >>>  
> >>> +static int nfsd_break_lease(struct inode *inode)
> >>> +{
> >>> +	if (!S_ISREG(inode->i_mode))
> >>> +		return 0;
> >>> +	return break_lease(inode, O_WRONLY | O_NONBLOCK);
> >> Hi Bruce,
> >>
> >> break_lease will return -EWOULDBLOCK here if break success, not 0.
> >>   at __break_lease:
> >>    
> >>     1193  */
> >>     1194 int __break_lease(struct inode *inode, unsigned int mode)
> >>     1195 {
> >>          ... ...  
> >>     1253         if (i_have_this_lease || (mode & O_NONBLOCK)) {
> >>     1254                 error = -EWOULDBLOCK;
> >>     1255                 goto out;
> >>     1256         }
> >>           ... ... 
> >>     1283 out:
> >>     1284         unlock_flocks();
> >>     1285         if (!IS_ERR(new_fl))
> >>     1286                 locks_free_lock(new_fl);
> >>     1287         return error;
> >>     1288 }
> >>
> >> If we just return the error -EWOULDBLOCK (which mapped to -EAGAIN) at
> >> nfsd_break_lease(), the NFS request will be drop for -EAGAIN is mapped
> >> to nfserr_dropit at nfserrno().
> > 
> > See my for-2.6.38-incoming branch (especially 062304a815fe and
> > surrounding).  I was getting tired of needing special handling for
> > EAGAIN and EWOULDBLOCK, so I removed that mapping and am setting a flag
> > on the rqstp instead to indicate the need to drop a request.
> > 
> > Does that look reasonable to you?
> 
>   I'm sorry for missing those patch you have post before,
>   I just test the two patch at v2.6.37. ^_^
> 
>   Those patch is great.
> 
>   According to the discussing before, after the two patch for breaking delegation,
>   a race as you said "
>     One problem is that there's a race: nothing I can see stops anyone from
>     getting another lease after may_delete() but before the delete happens."
>   also exist here. We can't make sure that a new delegation don't be granted
>   between nfsd_break_lease() and unlink file complete or rename complete. 

That's correct.  There are also at least a couple more preexisting races
in the lease code that can allow conflicting leases and opens.  Also,
this patch doesn't address the problem of unlinks and renames not done
by nfs clients.

--b.

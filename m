From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: directory attribute cache on NFS4 client
Date: Tue, 2 Sep 2008 13:50:47 -0400
Message-ID: <20080902175047.GA10855@fieldses.org>
References: <loom.20080829T132559-688@post.gmane.org> <loom.20080901T163528-489@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ricardo Santos <xscorpionbr-/E1597aS9LRfJ/NunPodnw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56921 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733AbYIBRuu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2008 13:50:50 -0400
In-Reply-To: <loom.20080901T163528-489-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 01, 2008 at 04:40:04PM +0000, Ricardo Santos wrote:
> I'm checking the NFS client code to understand it, and I saw this:
> 
> -- inode.c
> int nfs_attribute_timeout(struct inode *inode)
> {
>         struct nfs_inode *nfsi = NFS_I(inode);
> 
>         if (nfs_have_delegation(inode, FMODE_READ))
>                 return 0;
> 
> --
> 
> So, if a inode has a delegation, will it never be timed out, until the
> delegation been free, right ?
> 
> If the delegated inode has been deleted ?

The server should recall the delegation before allowing the delegated
file to be deleted.  (The current linux server is buggy--it doesn't do
that.  Patches are on the way soon, I hope....)

--b.

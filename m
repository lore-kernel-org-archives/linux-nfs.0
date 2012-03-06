Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:20858 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab2CFQO0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 11:14:26 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Apple Message framework v1257)
Subject: Fwd: NFS: Add a client-side function to display NFS file handles
From: Chuck Lever <chuck.lever@oracle.com>
Date: Tue, 6 Mar 2012 11:14:20 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <ACBA6BB2-0D59-45D0-82E1-770EF4C4F49A@oracle.com>
References: <20120306105134.GA1048@elgon.mountain>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond-

Can you please reverse these checks in your version of the commit?

Begin forwarded message:

> From: Dan Carpenter <dan.carpenter@oracle.com>
> Subject: re: NFS: Add a client-side function to display NFS file handles
> Date: March 6, 2012 5:51:35 AM EST
> To: chuck.lever@oracle.com
> Cc: linux-nfs@vger.kernel.org
> 
> Hello Chuck Lever,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 20d27e929fb4: "NFS: Add a client-side function to display 
> NFS file handles" from Mar 1, 2012, leads to the following Smatch 
> complaint:
> 
> fs/nfs/inode.c:1061 _nfs_display_fhandle()
> 	 warn: variable dereferenced before check 'fh' (see line 1061)
> 
> fs/nfs/inode.c
>  1060	
>  1061		if (fh->size == 0 || fh == NULL) {
>                    ^^^^^^^^         ^^^^^^^^^^
>                   dereference          check
> 
>  1062			printk(KERN_DEFAULT "%s at %p is empty\n", caption, fh);
>  1063			return;
> 
> regards,
> dan carpenter
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





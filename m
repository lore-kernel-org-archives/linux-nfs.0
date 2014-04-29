Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:15812 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933447AbaD2MQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2014 08:16:58 -0400
Date: Tue, 29 Apr 2014 08:16:35 -0400
From: Matthew Wilcox <willy@linux.intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 19/22] vfs: Cache richacl in struct inode
Message-ID: <20140429121635.GC5929@linux.intel.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1398615293-22931-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20140429005203.GT15995@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140429005203.GT15995@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 29, 2014 at 10:52:04AM +1000, Dave Chinner wrote:
> >  #ifdef CONFIG_FSNOTIFY
> > @@ -240,10 +246,19 @@ void __destroy_inode(struct inode *inode)
> >  	}
> >  
> >  #ifdef CONFIG_FS_POSIX_ACL
> > -	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
> > -		posix_acl_release(inode->i_acl);
> > -	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
> > -		posix_acl_release(inode->i_default_acl);
> > +	if (IS_POSIXACL(inode)) {
> > +		if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
> > +			posix_acl_release(inode->i_acl);
> > +		if (inode->i_default_acl &&
> > +		    inode->i_default_acl != ACL_NOT_CACHED)
> > +			posix_acl_release(inode->i_default_acl);
> > +	}
> > +#endif
> > +#ifdef CONFIG_FS_RICHACL
> > +	if (IS_RICHACL(inode)) {
> > +		if (inode->i_richacl && inode->i_richacl != ACL_NOT_CACHED)
> > +			richacl_put(inode->i_richacl);
> > +	}
> >  #endif
> 
> 	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
> 		acl_release(inode->i_acl);
> 
> And all the mess of working out what acl needs releasing get taken
> out of of this code.

Let's go further and have the API simply:

	inode_acl_release(inode);

with inode_acl_release looking something like:

	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
		acl_release(inode->i_acl);
	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
		acl_release(inode->i_default_acl);

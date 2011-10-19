Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:34760 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315Ab1JSFpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 01:45:13 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 25/26] ext4: Implement rich acl for ext4
In-Reply-To: <BCAE5666-30A1-484A-9808-B52E5B422A3F@dilger.ca>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1318951981-5508-26-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <BCAE5666-30A1-484A-9808-B52E5B422A3F@dilger.ca>
Date: Wed, 19 Oct 2011 11:13:40 +0530
Message-ID: <8739ep7cz7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 18 Oct 2011 12:41:15 -0600, Andreas Dilger <adilger@dilger.ca> wrote:
> On 2011-10-18, at 9:33 AM, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Support the richacl permission model in ext4.  The richacls are stored
> > in "system.richacl" xattrs.This need to be enabled by tune2fs or during
> > mkfs.ext4
> 
> It isn't clear from your commit comment or the code what needs to be enabled by tune2fs or mkfs.ext4.  Please list the specific ext4 feature
> that needs to be enabled.


The last patch explains the feature flag details 
http://article.gmane.org/gmane.linux.kernel/1204873

I am adding a new compat feature flag to indicate richacl is
enabled.

> 
> > +#ifdef CONFIG_EXT4_FS_RICHACL
> > +#define EXT4_IS_RICHACL(inode) IS_RICHACL(inode)
> > 
> 
> > +#else  /* CONFIG_FS_EXT4_RICHACL */
> > +
> > +#define EXT4_IS_RICHACL(inode) (0)
> 
> It is a bit confusing that you are using both EXT4_IS_RICHACL() and
> IS_RICHACL() in this code.  Initially I thought EXT4_IS_RICHACL() was
> checking an ext4-specific inode flag, but it seems that it is instead
> conditional upon the configure flags.
> 

The reason is to not do the superblock flag check when EXT4_FS_RICHACL is not
enabled.


> It looks like it should be possible to use EXT4_IS_RICHACL() in all
> of the code, since the richacl-specific code will not be compiled
> anyway.
> 

The reasoning is, all richacl specific code do check for whether
MS_RICHACL is enabled or not and the common file system code does
something similar to EXT4_IS_RICHACL() that is (0) when the file
system is not compiled with richacl option.

-aneesh

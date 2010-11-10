Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57174 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756327Ab0KJUbd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 15:31:33 -0500
Date: Wed, 10 Nov 2010 15:31:30 -0500
To: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Trond Myklebust <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 ACL set and inode attribute cache
Message-ID: <20101110203130.GD27237@fieldses.org>
References: <m3hbfpvz0k.fsf@linux.vnet.ibm.com>
 <m3eiatvwpc.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m3eiatvwpc.fsf@linux.vnet.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 11, 2010 at 12:21:27AM +0530, Aneesh Kumar K. V wrote:
> On Wed, 10 Nov 2010 23:31:31 +0530, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > 
> > Hi,
> > 
> > I guess we are not marking the inode attribute as invalid when we set
> > the ACL value. For ex:
> > 
> > /d# mkdir sub3
> > /d# ls -dl sub3
> > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > /d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
> > /d# ls -dl sub3
> > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > /d# 
> > 
> > 
> > On the server i have the mode bits as
> > /d# ls -dl sub3
> > drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
> > /d# 
> 
> We also have similar issue other way round. ie setting the mode bits
> don't result in ACL values being invalidated. But a second request get
> the right value of ACL as show below.

Both look like bugs to me.  (I remember their being pointed out before,
though--did we drop the ball, or was there some reason for the current
behavior?)

--b.

> 
> /d# nfs4_getfacl  x
> A::OWNER@:rw
> A::GROUP@:rw
> A::EVERYONE@:r
> /d# chmod 600 x
> /d# nfs4_getfacl  x
> A::OWNER@:rw
> A::GROUP@:rw
> A::EVERYONE@:r
> /d#
> 
> Expected value is
> 
> /d# nfs4_getfacl  x
> A::OWNER@:rw
> 
> -aneesh
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58273 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933691Ab1IIL44 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 07:56:56 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 9 Sep 2011 05:56:55 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: David Howells <dhowells@redhat.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self permission flags
In-Reply-To: <22928.1315563126@redhat.com>
References: <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <22928.1315563126@redhat.com>
Date: Fri, 09 Sep 2011 17:25:34 +0530
Message-ID: <87fwk63p6x.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 09 Sep 2011 11:12:06 +0100, David Howells <dhowells@redhat.com> wrote:
> Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> > +	    !inode_permission(inode, MAY_DELETE_SELF))
> > +		error = 0;
> 
> This might be easier to follow if you used == 0 rather than !.  The problem
> with ! is that it looks like:
> 
> 	not_have inode_permission.
> 
> I guess this is just one of the fun consequences of having 0 (false) meaning
> okay.
> 

Updated to do == 0 check

-aneesh


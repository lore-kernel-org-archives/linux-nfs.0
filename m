Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51937 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754769Ab1IHKgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 06:36:17 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 8 Sep 2011 06:36:13 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 17/26] richacl: Permission check algorithm
In-Reply-To: <20110907215022.GI8074@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110907215022.GI8074@fieldses.org>
Date: Thu, 08 Sep 2011 16:04:44 +0530
Message-ID: <877h5j5nln.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 7 Sep 2011 17:50:22 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Sep 05, 2011 at 10:55:39PM +0530, Aneesh Kumar K.V wrote:
> > From: Andreas Gruenbacher <agruen@kernel.org>
> > 
> > As in the standard POSIX file permission model, each process is the
> > owner, group, or other file class.  A process is
> > 
> >   - in the owner file class if it owns the file,
> >   - in the group file class if it is in the file's owning group or it
> >     matches any of the user or group entries, and
> >   - in the other file class otherwise.
> > 
> > Each file class is associated with a file mask.
> > 
> > A richacl grants a requested access if the NFSv4 acl in the richacl
> > grants the requested permissions (according to the NFSv4 permission
> > check algorithm) and the file mask that applies to the process includes
> > the requested permissions.
> 
> I assume that by default any ui normally recalculates an upper-bound
> mask automatically when you add an ace, as the posix setfacl does, so
> the user doesn't have to think about masks too much?
> 

yes. richacl userspace command does this.

-aneesh


From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2] register NFS_ACL with rpcbind
Date: Thu, 5 Nov 2009 11:56:15 -0500
Message-ID: <20091105165615.GD29981@fieldses.org>
References: <4AEF2D19.5090409@redhat.com> <4AEF562B.9070606@redhat.com> <20091104185848.GD11637@fieldses.org> <4AF1DBE4.1080103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, Olaf Kirch <okir@suse.de>,
	Andreas Gruenbacher <agruen@suse.de>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60119 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756912AbZKEQ4G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 11:56:06 -0500
In-Reply-To: <4AF1DBE4.1080103@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 04, 2009 at 02:54:12PM -0500, Peter Staubach wrote:
> J. Bruce Fields wrote:
> > Out of curiosity: have you tested a null rpc?
> > 
> 
> Yup.  "rpcinfo -t <server> nfs_acl" works like a charm
> with this patch applied for both versions 2 and 3.
> 
> > Also, doesn't v3 have the same problem?
> > 
> 
> Nope.  It already had a similar XDR routine.  Which is
> similar to the NFS XDR routine to do the same sort of
> thing.  I suppose that someday, we could clean them up,

Yes.

> but these routines aren't doing any harm for the moment.

OK.  Applied.

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51597 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbbELVoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2015 17:44:05 -0400
Date: Tue, 12 May 2015 17:44:03 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 12/45] richacl: Compute maximum file masks from an acl
Message-ID: <20150512214403.GB8980@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <922da02afd085be0d28d3c76f0b4fcb3b2e811f3.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <922da02afd085be0d28d3c76f0b4fcb3b2e811f3.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:04:09PM +0200, Andreas Gruenbacher wrote:
> Compute upper bound owner, group, and other file masks with as few
> permissions as possible without denying any permissions that the NFSv4
> acl in a richacl grants.
> 
> This algorithm is used when a file inherits an acl at create time and
> when an acl is set via a mechanism that does not provide file masks
> (such as setting an acl via nfsd).  When user-space sets an acl via
> setxattr, the extended attribute already includes the file masks.
> 
> Setting an acl also sets the file mode permission bits: they are
> determined by the file masks; see richacl_masks_to_mode().

Thanks, the verbose comments are welcomed here, just one typo:

> +	/*
> +	 * @gmask contains all permissions which the group class is ever
> +	 * allowed.  We use it to avoid adding permissions to the group mask
> +	 * from everyone@ allow aces which the group class is always denied
> +	 * through other aces.  For example, the following acl would otherwise
> +	 * result in a group mask or rw:

s/or/of/ ?

--b.

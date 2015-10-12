Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:12466 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752451AbbJLAWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Oct 2015 20:22:21 -0400
Date: Mon, 12 Oct 2015 11:22:00 +1100
From: Dave Chinner <david@fromorbit.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH v10 38/46] richacl: Add support for unmapped identifiers
Message-ID: <20151012002200.GB27164@dastard>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
 <1444604337-17651-39-git-send-email-andreas.gruenbacher@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444604337-17651-39-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 12:58:49AM +0200, Andreas Gruenbacher wrote:
> From: Andreas Gruenbacher <agruenba@redhat.com>
> 
> Some remote file systems like nfs may return user or group identifiers
> that cannot be mapped to local uids / gids.  Allow to represent such
> unmapped identifiers in richacls.  (We still cannot represent unmapped
> owners and owning groups, however.)
> 
> In the in-memory representation, the richacl is followed by a list of
> NUL-terminated strings, with no padding.  Entries with an unmapped
> identifier have the RICHACE_UNMAPPED_WHO flag set, and ace->e_id.offs
> specifies the offset into this list.  Multiple entries can refer to the
> same offset.
> 
> The xattr representation is similar, but ace->e_id is ignored, and the
> list of unmapped identifier strings contains a string for each acl entry
> whose RICHACE_UNMAPPED_WHO flag is set.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
....
> +/**
> + * richacl_has_unmapped_identifiers
> + *
> + * Check if an acl has unmapped identifiers.
> + */
> +bool richacl_has_unmapped_identifiers(struct richacl *acl)
> +{
> +	struct richace *ace;
> +
> +	richacl_for_each_entry(ace, acl) {
> +		if (ace->e_flags & RICHACE_UNMAPPED_WHO)
> +			return true;
> +	}
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(richacl_has_unmapped_identifiers);

This was used by the XFS support patch earlier in the series. Bisect
problem here...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:49250 "EHLO
        ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934736AbdLRWNJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Dec 2017 17:13:09 -0500
Date: Tue, 19 Dec 2017 09:07:59 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jan Kara <jack@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org, neilb@suse.de,
        jack@suse.de, linux-ext4@vger.kernel.org, tytso@mit.edu,
        adilger.kernel@dilger.ca, linux-xfs@vger.kernel.org,
        darrick.wong@oracle.com, linux-btrfs@vger.kernel.org, clm@fb.com,
        jbacik@fb.com, dsterba@suse.com, linux-integrity@vger.kernel.org,
        zohar@linux.vnet.ibm.com, dmitry.kasatkin@gmail.com,
        linux-afs@lists.infradead.org, dhowells@redhat.com,
        jaltman@auristor.com
Subject: Re: [PATCH v3 19/19] fs: handle inode->i_version more efficiently
Message-ID: <20171218220759.GF4094@dastard>
References: <20171218151156.14565-1-jlayton@kernel.org>
 <20171218151156.14565-20-jlayton@kernel.org>
 <20171218163418.GF30350@quack2.suse.cz>
 <1513617740.3422.30.camel@kernel.org>
 <20171218173651.GB12454@fieldses.org>
 <1513625720.3422.68.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1513625720.3422.68.camel@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 18, 2017 at 02:35:20PM -0500, Jeff Layton wrote:
> [PATCH] SQUASH: add memory barriers around i_version accesses

Why explicit memory barriers rather than annotating the operations
with the required semantics and getting the barriers the arch
requires automatically?  I suspect this should be using
atomic_read_acquire() and atomic_cmpxchg_release(), because AFAICT
the atomic_cmpxchg needs to have release semantics to match the
acquire semantics needed for the load of the current value.

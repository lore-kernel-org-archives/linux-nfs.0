Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33737 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761684AbcLPPlQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Dec 2016 10:41:16 -0500
Date: Fri, 16 Dec 2016 16:40:41 +0100
From: Michal Hocko <mhocko@kernel.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Dave Chinner <david@fromorbit.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>,
        Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org,
        linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH 2/9 v2] xfs: introduce and use KM_NOLOCKDEP to silence
 reclaim lockdep false positives
Message-ID: <20161216154041.GA7645@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161215140715.12732-3-mhocko@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Updated patch after Mike noticed a BUG_ON when KM_NOLOCKDEP is used.
---

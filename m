Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:14962 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754146Ab3LWQ7a convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Dec 2013 11:59:30 -0500
From: Chris Mason <clm@fb.com>
To: "hch@infradead.org" <hch@infradead.org>
CC: "jlbec@evilplan.org" <jlbec@evilplan.org>,
        "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>,
        "jfs-discussion@lists.sourceforge.net"
	<jfs-discussion@lists.sourceforge.net>,
        "mfasheh@suse.com" <mfasheh@suse.com>,
        "reiserfs-devel@vger.kernel.org" <reiserfs-devel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "andreas.gruenbacher@linbit.com" <andreas.gruenbacher@linbit.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-f2fs-devel@lists.sourceforge.net"
	<linux-f2fs-devel@lists.sourceforge.net>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "cluster-devel@redhat.com" <cluster-devel@redhat.com>
Subject: Re: [PATCH 00/21] Consolidate Posix ACL implementation V3
Date: Mon, 23 Dec 2013 16:57:58 +0000
Message-ID: <1387817904.8080.4.camel@ret.masoncoding.com>
References: <20131220131635.650823732@bombadil.infradead.org>
In-Reply-To: <20131220131635.650823732@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-12-20 at 05:16 -0800, Christoph Hellwig wrote:
+AD4- This series consolidates the various cut'n'pasted Posix ACL implementations
+AD4- into a single common one based on the -+AD4-get+AF8-acl method Linus added a while
+AD4- ago and a new -+AD4-set+AF8-acl counterpart.
+AD4- 
+AD4- This remove +AH4-1800 lines of code and provides a single place to implement
+AD4- various nasty little gems of the semantics.

Is this in a git tree somewhere?  I'll pull in and test the btrfs bits.

-chris


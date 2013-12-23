Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36924 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757490Ab3LWRBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Dec 2013 12:01:11 -0500
Date: Mon, 23 Dec 2013 09:01:03 -0800
From: "hch@infradead.org" <hch@infradead.org>
To: Chris Mason <clm@fb.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "jlbec@evilplan.org" <jlbec@evilplan.org>,
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
Message-ID: <20131223170103.GA14856@infradead.org>
References: <20131220131635.650823732@bombadil.infradead.org>
 <1387817904.8080.4.camel@ret.masoncoding.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1387817904.8080.4.camel@ret.masoncoding.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 23, 2013 at 04:57:58PM +0000, Chris Mason wrote:
> On Fri, 2013-12-20 at 05:16 -0800, Christoph Hellwig wrote:
> > This series consolidates the various cut'n'pasted Posix ACL implementations
> > into a single common one based on the ->get_acl method Linus added a while
> > ago and a new ->set_acl counterpart.
> > 
> > This remove ~1800 lines of code and provides a single place to implement
> > various nasty little gems of the semantics.
> 
> Is this in a git tree somewhere?

Only on my box.  Given how shitty kernel.org is to use these days I
don't bother with it anymore.


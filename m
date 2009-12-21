From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCHv2 00/12]posix_acl: Add the check items
Date: Mon, 21 Dec 2009 13:36:54 +0100
Message-ID: <20091221123654.GA9201__37381.0922181748$1261399205$gmane$org@lst.de>
References: <4B2F6153.8010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adilger@sun.com, jack@suse.cz, neilb@suse.de, jeffm@suse.com,
        bfields@fieldses.org, linux-mtd@lists.infradead.org,
        onlyflyer@gmail.com, hch@lst.de, tiger.yang@oracle.com,
        strongzgy@gmail.com, ffilzlnx@us.ibm.com, sandeen@sandeen.net,
        jmorris@namei.org, cluster-devel@redhat.com, aelder@sgi.com,
        cjb@laptop.org, bharrosh@panasas.com, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, xfs-masters@oss.sgi.com, viro@zeniv.linux.org.uk,
        chris.mason@oracle.com, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, serue@us.ibm.com, dwmw2@infradead.orgã,
        ocfs2-devel@oss.oracle.com
To: Liuwenyi <qingshenlwy@gmail.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <4B2F6153.8010609@gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

I like taking these checks into posix_acl_valid, but I think the patch
submission needs a bit more work.

All the patches are extremly whitespace mangled.  And I don't think
splitting them up makes a whole lot of sense, when we do API changes
like this we usually fix up all callers.  So please try to fix your
mailer, merged them all into one, and maybe also chose a more
descriptive subject line, e.g.

Subject: take checks for NULL and error pointers into posix_acl_valid()


And btw, at least the XFS change seems incorrect - previously we
returned NULL acl pointer and this patch changes it to -EINVAL.

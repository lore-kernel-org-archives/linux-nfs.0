From: liu weni <qingshenlwy@gmail.com>
Subject: Re: [PATCHv2 00/12]posix_acl: Add the check items
Date: Mon, 21 Dec 2009 22:15:26 +0800
Message-ID: <b3657a100912210615q1d55c334g73667e1c3a97ce05@mail.gmail.com>
References: <4B2F6153.8010609@gmail.com> <20091221123654.GA9201@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk,
	joel.becker@oracle.com, cjb@laptop.org, jmorris@namei.org,
	serue@us.ibm.com, akpm@linux-foundation.org, adilger@sun.com,
	jack@suse.cz, tytso@mit.edu, dwmw2@infradead.xn.org.cpa,
	swhiteho@redhat.com, bfields@fieldses.org, neilb@suse.de,
	ffilzlnx@us.ibm.com, bharrosh@panasas.com, mfasheh@suse.com,
	tiger.yang@oracle.com, jeffm@suse.com, aelder@sgi.com,
	sandeen@sandeen.net, xfs-masters@oss.sgi.com, xfs@oss.sgi.com,
	reiserfs-devel@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, cluster-devel@redhat.com,
	linux-mtd@lists.infradead.org, strongzgy@gmail.com,
	onlyflyer@gmail.com
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20091221123654.GA9201@lst.de>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for your suggestion.

In my opinion the null point is a incorrect state for the acl, then I
return -EINVAL.

I will check this state transition in XFS.

2009/12/21 Christoph Hellwig <hch@lst.de>:
> I like taking these checks into posix_acl_valid, but I think the patc=
h
> submission needs a bit more work.
>
> All the patches are extremly whitespace mangled. =A0And I don't think
> splitting them up makes a whole lot of sense, when we do API changes
> like this we usually fix up all callers. =A0So please try to fix your
> mailer, merged them all into one, and maybe also chose a more
> descriptive subject line, e.g.
>
> Subject: take checks for NULL and error pointers into posix_acl_valid=
()
>
>
> And btw, at least the XFS change seems incorrect - previously we
> returned NULL acl pointer and this patch changes it to -EINVAL.
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-ext4" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

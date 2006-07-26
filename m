From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 006 of 9] knfsd: Remove nfsd_versbits as intermediate storage for desired versions.
Date: Wed, 26 Jul 2006 15:34:42 -0400
Message-ID: <20060726193442.GF31172@fieldses.org>
References: <20060725114207.21779.patches@notabene> <1060725015452.21969@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932293AbWGZTeq@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060725015452.21969@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jul 25, 2006 at 11:54:52AM +1000, NeilBrown wrote:
> +int nfsd_vers(int vers, enum vers_op change)
> +{
> +	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
> +		return -1;

This isn't actually used; remove it or make it a BUG_ON()?

--b.

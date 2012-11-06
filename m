Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:42613
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750846Ab2KFNK2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Nov 2012 08:10:28 -0500
Date: Tue, 6 Nov 2012 08:10:18 -0500
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before
 connecting local transports
Message-ID: <20121106131018.GA12211@infradead.org>
References: <20121008105437.18668.99905.stgit@localhost.localdomain>
 <20121009193506.GA19680@fieldses.org>
 <5098E31A.5080801@parallels.com>
 <20121106120642.GA6718@fieldses.org>
 <20121106124035.GA20522@infradead.org>
 <20121106130705.GC6718@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121106130705.GC6718@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 06, 2012 at 08:07:06AM -0500, J. Bruce Fields wrote:
> So you're worried that a bug in the nfs code could modify the root and
> then not restore it?

At least the link you pointed to earlier never sets it back.  Instead
of messing with it I'd rather have the sunrpc code use vfs_path_lookup
and not care about current->fs->root at all.


Return-Path: linux-kernel-owner@vger.kernel.org
MIME-Version: 1.0
In-Reply-To: <7561c096c7de603ac39fcfcff7bd2ec80589cae1.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
	<7561c096c7de603ac39fcfcff7bd2ec80589cae1.1418618044.git.osandov@osandov.com>
Date: Mon, 15 Dec 2014 07:49:20 -0500
Message-ID: <CAABAsM4jMcox1emR1nSxORUOPNMDYmCcmMD4YymJ9R_BM_UU4w@mail.gmail.com>
Subject: Re: [PATCH 1/8] nfs: follow direct I/O write locking convention
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 15, 2014 at 12:26 AM, Omar Sandoval <osandov@osandov.com> wrote:
> The generic callers of direct_IO lock i_mutex before doing a write. NFS
> doesn't use the generic write code, so it doesn't follow this
> convention. This is now a problem because the interface introduced for
> swap-over-NFS calls direct_IO for a write without holding i_mutex, but
> other implementations of direct_IO will expect to have it locked.

I really don't care much about swap-over-NFS performance; that's a
niche usage at best. I _do_ care about O_DIRECT performance, and the
ability to run multiple WRITE calls in parallel.

IOW: Patch NACKed... Please find another solution.

Trond

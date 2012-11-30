Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:56932 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813Ab2K3AfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 19:35:05 -0500
Date: Fri, 30 Nov 2012 00:35:02 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Patrick McLean <patrickm@gaikai.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the
 dcache)
Message-ID: <20121130003502.GY4939@ZenIV.linux.org.uk>
References: <CAE2NFgU+4QDcLaVE5dKDvZCxey7qEf7FAbYNjNmcjVU=HLhF=A@mail.gmail.com>
 <20121129213316.GU4939@ZenIV.linux.org.uk>
 <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com>
 <20121129222109.GW4939@ZenIV.linux.org.uk>
 <50B7E759.9070007@gaikai.com>
 <20121129234326.GX4939@ZenIV.linux.org.uk>
 <50B7FBA7.2030300@gaikai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B7FBA7.2030300@gaikai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2012 at 04:19:51PM -0800, Patrick McLean wrote:
> >> [    8.821584] FH(0)]
> >> [    8.821586] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 a7 3c 1b 80 33 38 e3 62]
> >> [    8.821601] filename: proc
> > 
> > *whoa*
> > 
> > So we have zero entry->fh->size?  No wonder it doesn't match...  Which NFS
> > version it is?  entry->fh->size is set by nfs[34]_decode_dirent().
> 
> This is nfs v3 over TCP on Linus git at commit e9296e89b85604862bd9ec2d54dc43edad775c0d with nfs-utils-1.2.6 userspace.

So we have nfs3_decode_dirent(), stepping into
                /* In fact, a post_op_fh3: */
                p = xdr_inline_decode(xdr, 4);
                if (unlikely(p == NULL))
                        goto out_overflow;
                if (*p != xdr_zero) {
                        error = decode_nfs_fh3(xdr, entry->fh);
                        if (unlikely(error)) {
                                if (error == -E2BIG)
                                        goto out_truncated;
                                return error;
                        }
                } else
                        zero_nfs_fh3(entry->fh);
Interesting...  Server-side that should've been produced by
encode_entryplus_baggage(), which looks like failing compose_entry_fh()...
which has explicit
        if (d_mountpoint(dchild))
                goto out;
resulting in ENOENT on everything that's overmounted on server.

Do you, by any chance, have the server really exporting its own root
filesystem?  Another thing to check: have nfs_prime_dcache() print
filename.name of everything that fails nfs_same_entry() and has
zero entry->fh->size, regardless of d_invalidate() results.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:41757 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758017Ab2CFAIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 19:08:42 -0500
Date: Mon, 5 Mar 2012 19:08:37 -0500
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        "J. Bruce Fields" <bfields@redhat.com>, sandeen@redhat.com,
        adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120306000837.GA17164@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120109132158.2616029.30467.stgit@localhost.localdomain>
 <20120109132153.2616029.26302.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 09, 2012 at 02:21:53PM +0100, Bernd Schubert wrote:
> Just rename this variable, as the next patch will add a flag and
> 'access' as variable name would not be correct any more.
> 
> Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
> Acked-by: J. Bruce Fields<bfields@redhat.com>
> ---
>  fs/nfsd/vfs.c |   18 ++++++++++--------
>  1 files changed, 10 insertions(+), 8 deletions(-)

On Mon, Jan 09, 2012 at 02:21:58PM +0100, Bernd Schubert wrote:
> Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
> the NFS version. NFSv2 gets 32-bit hashes only.
> 
> NOTE: This patch got rather complex as Christoph asked to set the
> filp->f_mode flag in the open call or immediatly after dentry_open()
> in nfsd_open() to avoid races.
> Personally I still do not see a reason for that and in my opinion
> FMODE_32BITHASH/FMODE_64BITHASH flags could be set nfsd_readdir(), as it
> follows directly after nfsd_open() without a chance of races.
> 
> Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
> Acked-by: J. Bruce Fields<bfields@redhat.com>
> ---
>  fs/nfsd/vfs.c |   15 +++++++++++++--
>  fs/nfsd/vfs.h |    2 ++
>  2 files changed, 15 insertions(+), 2 deletions(-)

NFS folks,

Since Bruce has ack'ed these patches I assume it will be OK if I carry
them in the ext4 tree for merging?  (They depend on changes in ext4
found in the first two patches of these patch series.)

						- Ted

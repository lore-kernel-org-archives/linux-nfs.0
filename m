Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33198 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754112AbcHSV0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 17:26:03 -0400
Date: Fri, 19 Aug 2016 17:26:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trondmy.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version-2 00/12] NFSv4.2 inter server to server copy
Message-ID: <20160819212601.GT32329@fieldses.org>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I may not be able to review this carefully for a while.

Some general questions:

	- how are you testing this?
	- have you done any performance testing, and if so do you seem
	  to be getting expected bandwidth on the server-to-server copy?
	- is there wireshark support for the client-to-server and
	  server-to-server protocol?
	- how is the source server authorizing the copy?  Is GSSv3 still
	  needed for this eventually?

--b.

On Fri, Aug 19, 2016 at 01:25:00PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> 
> Anna's patches applied first:
> The first patch is a bug fix from Anna for the upstream Intra
> server to server copy.
> 
> The second patch has been submitted upstream, and is being
> reviewed by Bruce Fields.
> 
> The rest of the patches implement NFSv4.2 Intra-SSC
> 
> 
> Andy Adamson (9):
>   VFS permit cross device vfs_copy_file_range
>   NFS inter ssc open
>   NFS add COPY_NOTIFY operation
>   NFS add ca_source_server<> to COPY
>   NFSD add ca_source_server<> to COPY
>   NFSD add COPY_NOTIFY operation
>   NFSD generalize nfsd4_compound_state flag names
>   NFSD: allow inter server COPY to have a STALE source server fh
>   NFSD add nfs4 inter ssc to nfsd4_copy
> 
> Anna Schumaker (2):
>   fs: Don't copy beyond the end of the file
>   NFSD: Implement the COPY call
> 
> Olga Kornievskaia (1):
>   NFSD: extra stateid checking in read for interserver copy
> 
>  fs/nfs/internal.h         |  10 +
>  fs/nfs/nfs42.h            |   7 +-
>  fs/nfs/nfs42proc.c        | 128 ++++++++++-
>  fs/nfs/nfs42xdr.c         | 205 +++++++++++++++++-
>  fs/nfs/nfs4_fs.h          |   8 +
>  fs/nfs/nfs4file.c         | 135 +++++++++++-
>  fs/nfs/nfs4proc.c         |   6 +-
>  fs/nfs/nfs4state.c        |   2 +-
>  fs/nfs/nfs4xdr.c          |   1 +
>  fs/nfsd/Kconfig           |  10 +
>  fs/nfsd/nfs4proc.c        | 527 ++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/nfs4state.c       |  47 ++++-
>  fs/nfsd/nfs4xdr.c         | 272 +++++++++++++++++++++++-
>  fs/nfsd/nfsd.h            |   2 +
>  fs/nfsd/state.h           |   8 +
>  fs/nfsd/vfs.c             |   6 +
>  fs/nfsd/vfs.h             |   2 +
>  fs/nfsd/xdr4.h            |  50 ++++-
>  fs/read_write.c           |   8 +-
>  include/linux/nfs4.h      |  43 ++++
>  include/linux/nfs_fs_sb.h |   1 +
>  include/linux/nfs_xdr.h   |  20 ++
>  22 files changed, 1443 insertions(+), 55 deletions(-)
> 
> -- 
> 1.8.3.1

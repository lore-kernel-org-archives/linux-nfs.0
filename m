Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f169.google.com ([209.85.213.169]:52879 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab3HTUuV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Aug 2013 16:50:21 -0400
Received: by mail-ye0-f169.google.com with SMTP id r5so225851yen.14
        for <linux-nfs@vger.kernel.org>; Tue, 20 Aug 2013 13:50:20 -0700 (PDT)
Message-ID: <5213D689.3030103@gmail.com>
Date: Tue, 20 Aug 2013 16:50:17 -0400
From: Bryan Schumaker <bjschuma@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 00/16] NFS add tracepoints
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

This is what I see when I try to compile testing.

- Bryan


scripts/kconfig/conf --oldconfig Kconfig
#
# configuration written to .config
#
scripts/kconfig/conf --silentoldconfig Kconfig
make[1]: Nothing to be done for `all'.
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
make[1]: Nothing to be done for `relocs'.
  CALL    scripts/checksyscalls.sh
  CHK     include/generated/compile.h
make[3]: `arch/x86/realmode/rm/realmode.bin' is up to date.
  GZIP    kernel/config_data.gz
  CHK     kernel/config_data.h
  CC [M]  fs/nfs/nfstrace.o
In file included from fs/nfs/nfstrace.h:358:0,
                 from fs/nfs/nfstrace.c:9:
include/trace/define_trace.h:83:43: fatal error: ./nfstrace.h: No such file or directory
 #include TRACE_INCLUDE(TRACE_INCLUDE_FILE)
                                           ^
compilation terminated.
make[2]: *** [fs/nfs/nfstrace.o] Error 1
  CC [M]  fs/nfs/nfs4trace.o
In file included from fs/nfs/nfs4trace.h:1109:0,
                 from fs/nfs/nfs4trace.c:11:
include/trace/define_trace.h:83:43: fatal error: ./nfs4trace.h: No such file or directory
 #include TRACE_INCLUDE(TRACE_INCLUDE_FILE)
                                           ^
compilation terminated.
make[2]: *** [fs/nfs/nfs4trace.o] Error 1
make[2]: Target `__build' not remade because of errors.
make[1]: *** [fs/nfs] Error 2
make[1]: Target `__build' not remade because of errors.
make: *** [fs] Error 2
make: Target `_all' not remade because of errors.
nfs make  13.58s user 3.19s system 257% cpu 6.512 total


On 08/20/2013 03:34 PM, Trond Myklebust wrote:
> The following patchset sets up a number of ftrace tracepoints for use
> when debugging state operations and NFS performance issues.
> 
> Changes in v2:
>  - Fixed compile bugs
>  - We need to convert the delegation recall status to a negative number
>  - Added tracepoints for read/write, pnfs and slot table debugging.
> 
> Changes in v3:
>  - Added tracepoints for generic NFS code
>    - lookups
>    - atomic open
>    - inode cache consistency operations
>    - internal fsync and data flush operations
>  - Assorted cleanups and bugfixes
> 
> 
> Trond Myklebust (16):
>   NFS: refactor code for calculating the crc32 hash of a filehandle
>   NFS: Add event tracing for generic NFS events
>   NFS: Pass in lookup flags from nfs_atomic_open to nfs_lookup
>   NFS: Add event tracing for generic NFS lookups
>   NFSv4: Add tracepoints for debugging state management problems
>   NFSv4: Add tracepoints for debugging file open
>   NFSv4: Add tracepoints for debugging file locking
>   NFSv4: Add tracepoints for debugging lookup/create operations
>   NFSv4: Add tracepoints for debugging inode manipulations
>   NFSv4: Add tracepoints for debugging rename
>   NFSv4: Add tracepoints for debugging delegations
>   NFSv4: Add tracepoints for debugging the idmapper
>   NFSv4: Add tracepoints for debugging getattr
>   NFSv4: Add tracepoints for debugging reads and writes
>   NFSv4.1: Add tracepoints for debugging layoutget/return/commit
>   NFSv4.1: Add tracepoints for debugging slot table operations
> 
>  fs/nfs/Makefile         |    5 +-
>  fs/nfs/callback_proc.c  |    3 +
>  fs/nfs/delegation.c     |    3 +
>  fs/nfs/dir.c            |   27 +-
>  fs/nfs/file.c           |    5 +
>  fs/nfs/idmap.c          |    5 +
>  fs/nfs/inode.c          |   32 +-
>  fs/nfs/internal.h       |   20 +
>  fs/nfs/nfs4filelayout.c |    4 +
>  fs/nfs/nfs4proc.c       |  131 ++++--
>  fs/nfs/nfs4session.h    |   10 +
>  fs/nfs/nfs4trace.c      |   17 +
>  fs/nfs/nfs4trace.h      | 1109 +++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfstrace.c       |    9 +
>  fs/nfs/nfstrace.h       |  358 +++++++++++++++
>  fs/nfs/pnfs.c           |    3 +
>  fs/nfs/write.c          |   15 +-
>  17 files changed, 1705 insertions(+), 51 deletions(-)
>  create mode 100644 fs/nfs/nfs4trace.c
>  create mode 100644 fs/nfs/nfs4trace.h
>  create mode 100644 fs/nfs/nfstrace.c
>  create mode 100644 fs/nfs/nfstrace.h
> 


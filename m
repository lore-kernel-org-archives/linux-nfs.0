From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH 20/19] A basic NFSv4 client for 2.5.x
Date: 15 Oct 2002 00:46:25 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shsk7kkljum.fsf@charged.uio.no>
References: <15787.18187.306840.862917@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>,
	nfsv4-wg@citi.umich.edu
In-Reply-To: <15787.18187.306840.862917@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

     > This patch defines a new switch in fs/Config.in -
     >   CONFIG_NFS_V4: enables nfsv4 client

Please note: for those who are interested in trying this out, a patch
for the 'mount' program in util-linux-2.11r is available on

  http://www.fys.uio.no/~trondmy/src/NFSv4/mount-2.11r-nfsv4.patch

Note however that the NFS client is not yet fully functional, as it
lacks the upcall + RPCSEC_GSS. These features are forthcoming...

Cheers,
  Trond

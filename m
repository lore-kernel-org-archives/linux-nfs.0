From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Disabling Symbolic Link Content Caching in NFS Client
Date: Mon, 2 Jun 2003 23:48:18 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16091.50722.851659.821544@charged.uio.no>
References: <2BB7146B38D9CA40B215AB3DAAE24C080BA4F3@blr-m2-msg.wipro.com>
	<200306022037.h52KbNVh012849@buggy.badula.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vivek Goyal" <vivek.goyal@wipro.com>,
	<indou.takao@jp.fujitsu.com>, <ezk@cs.sunysb.edu>,
	<viro@math.psu.edu>, <davem@redhat.com>,
	<nfs@lists.sourceforge.net>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <200306022037.h52KbNVh012849@buggy.badula.org>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Ion Badulescu <ionut@badula.org> writes:

    >> 1. Make nfs_symlink_caching dynamically tunable using /proc and
    >> sysctl interface.

     > No. Do it on a per-mount basis, like the other OS's do.

As I said to Vivek in a private mail, it would be very nice to see
if this could be done by replacing hlfsd with namespace groups.

Al Viro has already done all the VFS layer work, which should be ready
and working in existing 2.4.20 and 2.5.x kernels. What is missing is
userland support for doing a CLONE_NEWNS, and then mounting the user's
home directory, mailspool,.... in the appropriate locations at login
time.

Cheers,
  Trond

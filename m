From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Disabling Symbolic Link Content Caching in NFS Client
Date: Mon, 2 Jun 2003 23:56:16 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16091.51200.292233.374385@charged.uio.no>
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

     > Replacing a couple of time_after() calls with time_after_eq()
     > calls fixes the issue, at least for hlfsd.

BTW: the above does not suffice to eliminate all races. Two processes
owned by different users may still end up waiting on the same call to
nfs_symlink_filler() no matter how often you choose to update the
metadata.

Cheers,
 Trond

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [NFS] Disabling Symbolic Link Content Caching in NFS Client
Date: Tue, 3 Jun 2003 18:05:09 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16092.50997.483311.566882@charged.uio.no>
References: <2BB7146B38D9CA40B215AB3DAAE24C080BA622@blr-m2-msg.wipro.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ion Badulescu" <ionut@badula.org>, <viro@math.psu.edu>,
	<davem@redhat.com>, <ezk@cs.sunysb.edu>,
	<indou.takao@jp.fujitsu.com>, <nfs@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Vivek Goyal" <vivek.goyal@wipro.com>
In-Reply-To: <2BB7146B38D9CA40B215AB3DAAE24C080BA622@blr-m2-msg.wipro.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Vivek Goyal <vivek.goyal@wipro.com> writes:

     > You are right. But our idea is to provide an option to
     > disable/enable caching based on the nature of intended
     > application.

Apart from hlfsd, which applications actually depend on symlinks not
being cached?

     > With this, Linux will have enhanced flexibility in NFS client
     > like other operating systems. For example.

Again: Do you have any concrete examples of programs that need this
functionality, and that cannot be replaced?

Cheers,
  Trond

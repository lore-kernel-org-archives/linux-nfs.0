From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Fri, 05 Oct 2007 13:36:19 -0400
Message-ID: <1191605779.6715.86.camel@heimdal.trondhjem.org>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	 <20071004085206.0a8e37b5@poseidon.drzeus.cx>
	 <1191506450.6685.17.camel@heimdal.trondhjem.org>
	 <20071004184304.6e71ab6d@poseidon.drzeus.cx>
	 <20071004114243.3161af16.akpm@linux-foundation.org>
	 <1191525363.6739.12.camel@heimdal.trondhjem.org>
	 <47054205.8000908@redhat.com>  <20071005082513.4b5a058c@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761328AbXJERg4@vger.kernel.org>
In-Reply-To: <20071005082513.4b5a058c@poseidon.drzeus.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 2007-10-05 at 08:25 +0200, Pierre Ossman wrote:

> Print a warning or something so that they can be found. Don't go
> breaking systems left and right. People have better things to do than
> to fix the build systems for ever program they use.

The kernel knows bugger all about what glibc function your program is
calling. The problem here is precisely that newer versions of glibc will
transform legacy 32-bit stat() calls into 64-bit stat64() calls, then
will complain when the result overflows.

If you want to figure out which apps are broken, then you will have to
either do so in glibc or use a preloaded shared library to intercept the
32-bit stat() calls and print out a warning.

Trond

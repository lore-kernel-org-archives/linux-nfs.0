From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Ext2-devel] Re: [NFS] htree+NFS (NFS client bug?)
Date: Thu, 28 Nov 2002 03:46:00 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15845.33640.256556.123111@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
	<shsptsrd761.fsf@charged.uio.no>
	<1038387522.31021.188.camel@ixodes.goop.org>
	<20021127150053.A2948@redhat.com>
	<1038449223.1464.17.camel@ixodes.goop.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stephen C. Tweedie" <sct@redhat.com>,
	Ext2 devel <ext2-devel@lists.sourceforge.net>,
	NFS maillist <nfs@lists.sourceforge.net>,
	Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <1038449223.1464.17.camel@ixodes.goop.org>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Jeremy Fitzhardinge <jeremy@goop.org> writes:

     > Hm, I just did a run with 8k NFS packets, and the results are
     > slightly different.  There's only a single READDIR reply,
     > fragmented over 3 IP packets.  vg_include.h~51-kill-inceip
     > still has a cookie of 1611747420, and vg_libpthread.vs is still
     > the last entry returned, but it has a cookie of 0.  As far as I
     > can see, all the other cookies are unique.

AFAICS, the ext2/ext3 code is simply failing to initialize that last
cookie, and so knfsd is giving it the value of the cookie that was
passed by the client.

Cheers,
  Trond

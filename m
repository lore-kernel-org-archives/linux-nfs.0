From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] htree+NFS (NFS client bug?)
Date: 27 Nov 2002 04:26:46 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shsptsrd761.fsf@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ext2 devel <ext2-devel@lists.sourceforge.net>,
	NFS maillist <nfs@lists.sourceforge.net>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Jeremy Fitzhardinge <jeremy@goop.org> writes:

     > It looks to me like some sort of problem managing the NFS
     > readdir cookies, but it isn't clear to me whether this is the
     > NFS server/ext3 generating bad cookies, or the NFS client
     > handling them wrongly.

In order to determine which of the two needs to be fixed, it would
help if you could print out the cookies from that listing or better
still: if you could provide us with the raw tcpdump output. Please
remember to use an 8k snaplen for the tcpdump...

Cheers,
  Trond

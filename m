From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Ext2-devel] Re: [NFS] htree+NFS (NFS client bug?)
Date: Wed, 27 Nov 2002 21:25:35 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15845.10815.450247.316196@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
	<shsptsrd761.fsf@charged.uio.no>
	<1038387522.31021.188.camel@ixodes.goop.org>
	<20021127150053.A2948@redhat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ext2 devel <ext2-devel@lists.sourceforge.net>,
	NFS maillist <nfs@lists.sourceforge.net>,
	Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <20021127150053.A2948@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:

     > So I suspect that this is a root a client problem --- the
     > client has repeated a READDIR despite being told that the
     > previous reply was EOF

I disagree. As far as the client is concerned, it has just been asked
to read the entry that corresponds to that particular cookie.  If
glibc issued a new readdir request (which is what I suspect has
happened here), the NFS client has no idea what the previous reply
was, or even where it was positioned within the page cache (the latter
may have been cleared). All it can do is look up the cookie afresh and
start reading from there.

IOW: A cookie should *always* be unique. There are no exceptions to
this rule.

Cheers,
  Trond

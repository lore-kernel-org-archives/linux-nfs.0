From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Ext2-devel] Re: [NFS] htree+NFS (NFS client bug?)
Date: 27 Nov 2002 23:44:01 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shslm3e4or2.fsf@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
	<shsptsrd761.fsf@charged.uio.no>
	<1038387522.31021.188.camel@ixodes.goop.org>
	<20021127150053.A2948@redhat.com>
	<15845.10815.450247.316196@charged.uio.no>
	<20021127205554.J2948@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ext2 devel <ext2-devel@lists.sourceforge.net>,
	NFS maillist <nfs@lists.sourceforge.net>,
	Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <20021127205554.J2948@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:

    >> If glibc issued a new readdir request (which is what I suspect
    >> has happened here), the NFS client has no idea what the
    >> previous reply was

     > Well, glibc will *always* issue another readdir, because the
     > only way we can ever tell glibc that we're at EOF on the
     > directory is when we eventually return 0 from getdents.  The
     > question about client behaviour is, if we've already been told
     > that the stream is at EOF, should the client simply discard
     > that info and keep reading regardless, or should it cache the
     > EOF status?

We could possibly cache the EOF status by overloading some other field
in the struct file. f_version comes to mind as a useful candidate,
since it automatically gets reset by llseek.

Cheers,
  Trond

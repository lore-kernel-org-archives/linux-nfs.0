Return-Path: bfields@fieldses.org
Date: Thu, 18 Dec 2014 12:18:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Holger =?utf-8?Q?Hoffst=C3=A4tte?= <holger.hoffstaette@googlemail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
Message-ID: <20141218171852.GH18179@fieldses.org>
References: <pan.2014.12.16.22.19.18@googlemail.com>
 <20141217212159.GA11517@fieldses.org>
 <5492C710.20104@googlemail.com>
 <20141218144856.GA18179@fieldses.org>
 <alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
 <20141218151914.GB18179@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141218151914.GB18179@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 18, 2014 at 10:19:14AM -0500, J. Bruce Fields wrote:
> On Thu, Dec 18, 2014 at 09:58:06AM -0500, Benjamin Coddington wrote:
> > Frame 36 of nfs-client.pcap has this interesting string:
> > 
> > 0ff0  00 01 3b f6 fb b6 26 16 8f 7c 00 00 00 41 62 74   ..;...&..|...Abt
> > 1000  72 66 73 2d 32 30 00 00 00 00 00 00 00 00 30 36   rfs-20........06
> > 1010  2d 66 69 78 2d 64 65 61 64 6c 6f 63 6b 2d 77 68   -fix-deadlock-wh
> > 1020  65 6e 2d 6d 6f 75 6e 74 69 6e 67 2d 61 2d 64 65   en-mounting-a-de
> > 1030  67 72 61 64 65 64 2d 66 73 2e 70 61 74 63 68 00   graded-fs.patch.
> 
> Yes, that looks like the server messing up the encoding of the reply.

And indeed looking at the git repo that matches up with the entry:

	btrfs-20........06-fix-deadlock-when-mounting-a-degraded-fs.patch.
	btrfs-20140619-006-fix-deadlock-when-mounting-a-degraded-fs.patch

So a stray 8 bytes of zeroes got written there.

And the reply also ends with 000000017fffffff when I believe it should
end with two 4-byte 0's (no value follows, not EOF).

So I think those 0's got written to the wrong offset.  That should be
enough information to find the bug....

--b.

From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: RFC: adding an "fs" directory under /sys
Date: Sat, 17 Apr 2004 21:07:40 +0100
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20040417200740.GB17014@parcelfarce.linux.theplanet.co.uk>
References: <482A3FA0050D21419C269D13989C61130435DEFD@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Patrick Mochel <mochel@digitalimplant.org>,
	nfs@lists.sourceforge.net, Linus Torvalds <torvalds@osdl.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DEFD@lavender-fe.eng.netapp.com>
List-ID: <nfs.lists.sourceforge.net>

On Sat, Apr 17, 2004 at 12:46:05PM -0700, Lever, Charles wrote:
> i've been working on a patch set that will expose I/O counters
> for NFS mount points.  we're considering exposing these counters
> via /sys.
> 
> i'm thinking this should go under /sys/fs, where there is one
> subdirectory in /sys/fs for each file system type available
> on the system.

Hell, *no*.  Goddamnit, people, just how many times should that story repeat
itself before it sinks into your skulls - DO NOT MESS WITH KOBJECTS UNLESS
YOU UNDERSTAND LIFETIME RULES.

	Linus, please consider that as a formal veto on any patches embedding
kobjects into struct super_block unless they are accompanied by detailed
analysis of lifetime rules _AND_ had been reviewed and ACKed on linux-kernel
and linux-fsdevel.

From: Andi Kleen <ak@muc.de>
Subject: Re: x86_64: 32bit emulation problems
Date: 1 Mar 2005 23:19:02 +0100
Message-ID: <20050301221902.GA73844@muc.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de> <20050301202417.GA40466@muc.de> <200503012207.02915.bernd-schubert@web.de> <jewtsruie9.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernd Schubert <bernd-schubert@web.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Date: Tue, 1 Mar 2005 23:19:02 +0100
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <jewtsruie9.fsf@sykes.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Mar 01, 2005 at 11:10:38PM +0100, Andreas Schwab wrote:
> That's because there are some values in the stat64 buffer delivered by the
> kernel which cannot be packed into the stat buffer that you pass to stat.
> Use stat64 or _FILE_OFFSET_BITS=64.

If that had been the case strace would have reported EOVERFLOW
or E2BIG. But it returned 0 according to the log that was posted.

-Andi

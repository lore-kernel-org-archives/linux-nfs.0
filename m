From: Andi Kleen <ak@muc.de>
Subject: Re: x86_64: 32bit emulation problems
Date: 2 Mar 2005 00:07:49 +0100
Message-ID: <20050301230749.GA79861@muc.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de> <200503012207.02915.bernd-schubert@web.de> <20050301214832.GA44624@muc.de> <200503012330.42154.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Date: Wed, 2 Mar 2005 00:07:49 +0100
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200503012330.42154.bernd-schubert@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> stat64("/mnt/test/yp", {st_mode=S_IFDIR|0755, st_size=2704, ...}) = 0

It returns 0. No error.  Someone else in user space must be adding the EOVERFLOW.
glibc code does quite a lot of strange things with stat, perhaps
it comes from there.

> write(2, "err = -1\n", 9err = -1
> )               = 9
> write(2, "stat for /mnt/test/yp failed \n", 30stat for /mnt/test/yp failed
> ) = 30
> write(2, "ernno: 75 (Value too large for d"..., 50ernno: 75 (Value too large 
> for defined data type)
> ) = 50
> exit_group(0)                           = ?

-Andi

From: Andi Kleen <ak@muc.de>
Subject: Re: x86_64: 32bit emulation problems
Date: 1 Mar 2005 21:24:17 +0100
Message-ID: <20050301202417.GA40466@muc.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net, bernd-schubert@gmx.de
Date: Tue, 1 Mar 2005 21:24:17 +0100
To: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
In-Reply-To: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> 32bit:
> ------
> hitchcock:/home/bernd/src/tests# strace32 ./test_stat32 /mnt/test/yp
> execve("./test_stat32", ["./test_stat32", "/mnt/test/yp"], [/* 39 vars */]) = 
> 0
> uname({sys="Linux", node="hitchcock", ...}) = 0
> brk(0)                                  = 0x80ad000
> brk(0x80ce000)                          = 0x80ce000
> stat64("/mnt/test/yp", {st_mode=S_IFDIR|0755, st_size=2704, ...}) = 0

It returns 0 which is success. How can it match this code? 

	if (stat (dir, &buf) == -1)
                 fprintf(stderr, "stat for %s failed \n", dir);

It is most likely some kind of user space problem.  I would change
it to int err = stat(dir, &buf);
and then go through it with gdb and see what value err gets assigned.

I cannot see any kernel problem.

> write(2, "stat for /mnt/test/yp failed \n", 30stat for /mnt/test/yp failed 
> ) = 30
> exit_group(0)                           = ?

-Andi

From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Tue, 1 Mar 2005 22:07:01 +0100
Message-ID: <200503012207.02915.bernd-schubert@web.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de> <20050301202417.GA40466@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050301202417.GA40466@muc.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hello Andi,

sorry, due to some mail sending/refusing problems, I had to resend to t=
he=20
nfs-list, which prevented the answers there to be posted to the other C=
Cs.

> It is most likely some kind of user space problem.  I would change
> it to int err =3D stat(dir, &buf);
> and then go through it with gdb and see what value err gets assigned.
>
> I cannot see any kernel problem.

The err value will become -1 here.

 Trond Myklebust already suggested to look at the results of errno:

On Tuesday 01 March 2005 00:43, Bernd Schubert wrote:
> On Monday 28 February 2005 23:26, you wrote:
> > Given that strace shows that both syscalls (stat64() and stat())
> > succeed, I expect the "problem" is probably just glibc setting an
> > EOVERFLOW error in the 32-bit case. That's what it is supposed to d=
o if
> > a 64 bit value overflows the 32-bit buffers.
>
> Right, thanks.
>
> > Have you tried looking at errno?
>
> bernd@hitchcock tests>./test_stat32 /mnt/test/yp
> stat for /mnt/test/yp failed
> ernno: 75 (Value too large for defined data type)
>
> But why does stat64() on a 64-bit kernel tries to fill in larger data=
 than
> on a 32-bit kernel and larger data also only for nfs-mount points? Hm=
m, I
> will tomorrow compare the tcp-packges sent by the server.

So I still think thats a kernel bug.


Thanks,
 Bernd

--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

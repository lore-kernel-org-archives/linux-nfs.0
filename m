From: Andreas Schwab <schwab@suse.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Tue, 01 Mar 2005 23:10:38 +0100
Message-ID: <jewtsruie9.fsf@sykes.suse.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de>
	<20050301202417.GA40466@muc.de>
	<200503012207.02915.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andi Kleen <ak@muc.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200503012207.02915.bernd-schubert@web.de> (Bernd Schubert's
 message of "Tue, 1 Mar 2005 22:07:01 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Bernd Schubert <bernd-schubert@web.de> writes:

>> It is most likely some kind of user space problem.  I would change
>> it to int err =3D stat(dir, &buf);
>> and then go through it with gdb and see what value err gets assigned=
=2E
>>
>> I cannot see any kernel problem.
>
> The err value will become -1 here.

That's because there are some values in the stat64 buffer delivered by =
the
kernel which cannot be packed into the stat buffer that you pass to sta=
t.
Use stat64 or _FILE_OFFSET_BITS=3D64.

>  Trond Myklebust already suggested to look at the results of errno:
>
> On Tuesday 01 March 2005 00:43, Bernd Schubert wrote:
>> On Monday 28 February 2005 23:26, you wrote:
>> > Given that strace shows that both syscalls (stat64() and stat())
>> > succeed,

The trace does not say anything about the user-level stat().

>> bernd@hitchcock tests>./test_stat32 /mnt/test/yp
>> stat for /mnt/test/yp failed
>> ernno: 75 (Value too large for defined data type)
>>
>> But why does stat64() on a 64-bit kernel tries to fill in larger dat=
a than
>> on a 32-bit kernel and larger data also only for nfs-mount points? H=
mm, I
>> will tomorrow compare the tcp-packges sent by the server.
>
> So I still think thats a kernel bug.

This has nothing to do with the kernel.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

From: Andreas Schwab <schwab@suse.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Wed, 02 Mar 2005 00:22:05 +0100
Message-ID: <jek6oruf36.fsf@sykes.suse.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de>
	<20050301202417.GA40466@muc.de>
	<200503012207.02915.bernd-schubert@web.de>
	<jewtsruie9.fsf@sykes.suse.de> <20050301221902.GA73844@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Bernd Schubert <bernd-schubert@web.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050301221902.GA73844@muc.de> (Andi Kleen's message of "1 Mar
 2005 23:19:02 +0100, Tue, 1 Mar 2005 23:19:02 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Andi Kleen <ak@muc.de> writes:

> On Tue, Mar 01, 2005 at 11:10:38PM +0100, Andreas Schwab wrote:
>> That's because there are some values in the stat64 buffer delivered =
by the
>> kernel which cannot be packed into the stat buffer that you pass to =
stat.
>> Use stat64 or _FILE_OFFSET_BITS=3D64.
>
> If that had been the case strace would have reported EOVERFLOW
> or E2BIG.

No, the values are ok for stat64.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

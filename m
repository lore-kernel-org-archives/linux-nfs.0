From: Andreas Schwab <schwab@suse.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Wed, 02 Mar 2005 00:39:02 +0100
Message-ID: <jefyzfueax.fsf@sykes.suse.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de>
	<200503012207.02915.bernd-schubert@web.de>
	<jewtsruie9.fsf@sykes.suse.de>
	<200503020019.20256.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andi Kleen <ak@muc.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200503020019.20256.bernd-schubert@web.de> (Bernd Schubert's
 message of "Wed, 2 Mar 2005 00:19:19 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Bernd Schubert <bernd-schubert@web.de> writes:

> Hmm, after compiling with -D_FILE_OFFSET_BITS=3D64 it works fine. But=
 why does=20
> it work without this option on a 32bit kernel, but not on a 64bit ker=
nel?

Most likely the inode number (which is the only non-filesize related it=
em
that is different between struct stat and struct stat64) overflows ino_=
t.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

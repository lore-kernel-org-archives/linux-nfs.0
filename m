From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Wed, 2 Mar 2005 00:19:19 +0100
Message-ID: <200503020019.20256.bernd-schubert@web.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de> <200503012207.02915.bernd-schubert@web.de> <jewtsruie9.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Andi Kleen <ak@muc.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <jewtsruie9.fsf@sykes.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday 01 March 2005 23:10, Andreas Schwab wrote:
> Bernd Schubert <bernd-schubert@web.de> writes:
> >> It is most likely some kind of user space problem.  I would change
> >> it to int err = stat(dir, &buf);
> >> and then go through it with gdb and see what value err gets assigned.
> >>
> >> I cannot see any kernel problem.
> >
> > The err value will become -1 here.
>
> That's because there are some values in the stat64 buffer delivered by the
> kernel which cannot be packed into the stat buffer that you pass to stat.
> Use stat64 or _FILE_OFFSET_BITS=64.

Hmm, after compiling with -D_FILE_OFFSET_BITS=64 it works fine. But why does 
it work without this option on a 32bit kernel, but not on a 64bit kernel?

32bit kernel, 32bit binary: always works
64bit kernel, 64bit binary: always works

64bit kernel, 32bit binary:
 - always works on knfsd mount points
 - always works with -D_FILE_OFFSET_BITS=64
 - only works on unfs3 mount points with _FILE_OFFSET_BITS=64 


Do I really have to write a bug report for every single debian package that 
access /etc  and /var to make the maintainers recompile it with 
-D_FILE_OFFSET_BITS=64? 
Btw, whats about Suse, are there all packages compiled with this option? ;)


Cheers, 
(a completely confused) Bernd

From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfsd-fh: found a name that I didn't expect
Date: Sat, 29 Mar 2003 12:54:02 +0100
Sender: bernd-schubert@web.de
Message-ID: <200303291254.02498.bernd-schubert@web.de>
References: <200303281828.55093.bernd-schubert@web.de> <20030329140145.A24789@namesys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net,
 reiserfs-list@namesys.com
Return-path: <reiserfs-list-return-13426-reiserfs=m.gmane.org@namesys.com>
list-help: <mailto:reiserfs-list-help@namesys.com>
list-unsubscribe: <mailto:reiserfs-list-unsubscribe@namesys.com>
list-post: <mailto:reiserfs-list@namesys.com>
Errors-To: flx@namesys.com
To: Oleg Drokin <green@namesys.com>
In-Reply-To: <20030329140145.A24789@namesys.com>
List-ID: <nfs.lists.sourceforge.net>

On Saturday 29 March 2003 12:01, you wrote:
> Hello!
>
> On Fri, Mar 28, 2003 at 06:28:55PM +0100, Bernd Schubert wrote:
> > due to hardware problems I just started our fall back server and got
> > these messages for 2 files:
> > nfsd-fh: found a name that I didn't expect: bin/uptime
> > nfsd-fh: found a name that I didn't expect: bin/uptime
> > nfsd: last server has exited
> > nfsd: unexporting all filesystems
> > nfsd-fh: found a name that I didn't expect: lib/libident.so.0
> > nfsd-fh: found a name that I didn't expect: lib/libident.so.0
>
> Hm. Does the message is visible each time you access those files?

Yes, probably since uptime and libident.so.0 were called in and endless loop 
from the clients, the nfs-servers log was filled with those messages and I 
had to stop the nfsd and do the cp- and mv-procedure for those files.

> Does reiserfsck have found anything?

As I said, the backup script runs a reiserfsck itself and found no problems, I 
hope there is no corruption after a simple boot, but I will check this later 
on this day.

>
> > Any ideas how we can prevent this in the future ?
>
> We do not yet understand on how to reproduce that locally, because this
> message indicates pretty strange conditions.

Is there anything I can do to debug this, when I observe this phenomena the 
next time  (e.g. enabling nfs-debugging via proc, etc) ?

Thanks,
	Bernd

From: Oleg Drokin <green@namesys.com>
Subject: Re: nfsd-fh: found a name that I didn't expect
Date: Sat, 29 Mar 2003 14:01:45 +0300
Message-ID: <20030329140145.A24789@namesys.com>
References: <200303281828.55093.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, reiserfs-list@namesys.com
Return-path: <reiserfs-list-return-13425-reiserfs=m.gmane.org@namesys.com>
list-help: <mailto:reiserfs-list-help@namesys.com>
list-unsubscribe: <mailto:reiserfs-list-unsubscribe@namesys.com>
list-post: <mailto:reiserfs-list@namesys.com>
Errors-To: flx@namesys.com
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200303281828.55093.bernd-schubert@web.de>
List-ID: <nfs.lists.sourceforge.net>

Hello!

On Fri, Mar 28, 2003 at 06:28:55PM +0100, Bernd Schubert wrote:
> due to hardware problems I just started our fall back server and got these 
> messages for 2 files:
> nfsd-fh: found a name that I didn't expect: bin/uptime
> nfsd-fh: found a name that I didn't expect: bin/uptime
> nfsd: last server has exited
> nfsd: unexporting all filesystems
> nfsd-fh: found a name that I didn't expect: lib/libident.so.0
> nfsd-fh: found a name that I didn't expect: lib/libident.so.0

Hm. Does the message is visible each time you access those files?
Does reiserfsck have found anything?

> Any ideas how we can prevent this in the future ?

We do not yet understand on how to reproduce that locally, because this message
indicates pretty strange conditions.

Bye,
    Oleg

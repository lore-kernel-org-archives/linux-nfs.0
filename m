From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS mount option - noac forces sync even if async is sp
	ecified, and no warning is given
Date: Wed, 5 Feb 2003 10:28:09 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D552A1@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18gUHX-0005BN-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Feb 2003 10:28:23 -0800
To: "'Heflin, Roger A.'" <Roger.A.Heflin@conocophillips.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi roger-

> > noac without sync writes doesn't make much sense, does it?
> > noac is used to cause multiple clients to share files pretty
> > tightly.  even if client A is aggressively checking a server
> > for changes to a file, it will not detect changes unless
> > all the other clients send their writes as submitted by the
> > app, rather than delaying them.
> > 
> > solaris noac has always behaved this way, and Linux noac
> > has behaved like this since around 2.4.7.
> > 
> 	We don't expect to get the writes another client does 
> 	immediately, we want to see the file creates/attribute changes
> 	close to real time, not the data itself, the applications have
> 	a way of dealing with the data not being in sync, and don't
> 	even expect it to be consistant over the short term.

then trond's suggestion of reducing the attribute cache timeout
values to zero is your answer for now.

> 	I think the problem is with the name, noac which is explained
> 	as no attribute caching, and on Suns it is explained as no
> 	data and attribute caching (I just checkd the man) not exactly
> 	a consistant naming on Sun's part.  It should probably be 
> 	called nocache since that appears to be what it is doing.

ah, but Solaris noac doesn't disable *data* caching.  data is still
cached until the client detects the file has changed.  *writes* are
no longer cached, but reads can hit the client's data cache as long
as the file doesn't change on the server.

only forcedirectio on Solaris causes no *data* caching.

you have to understand the history of "noac" to understand why it
works this way.  noac is a mechanism for forcing clients to use very
tight coherency amongst one another.  its traditional usage is when
an MTA runs on the NFS server, and the clients (workstations) have
the MUAs.  there needs to be a tight interaction between the MTA
and MUAs in order for the mail clients to see mail appear in their
spool immediately when it arrives, and for the MTA to see file size
changes when an MUA deletes a mail item.

to do that, you need both aggressive cache checking, and you need
the client to flush writes immediately.  just like in close-to-open
you need both GETATTR on open(), and flush on close().

the name "noac" is traditional, and very possibly in the beginning
it meant only that attributes were not cached, and did not affect
write behavior.  i'm sure the veterans on this list will correct
me if i'm wrong.

> > > If I remove the noac option, then the async option seems to 
> > > be honered, but not with the noac option on the line, is this 
> > > the documented 
> > > behavior?  And should something give a warning since one user 
> > > specified options overrides another user specified option in a 
> > > very nonobvious way?
> > 
> > noac is a synonym for "actimeo=0,sync" which is the behavior
> > of least surprise in this case.  if you look at the Solaris
> > man page which describes noac, you will see that Solaris's noac
> > behaves this way.  maybe the Linux mount_nfs man page hasn't
> > been updated to reflect this behavior.
> > 
> 	It is only the behavior of least suprise if you are 
> using Solaris
> 	as the reference, not if you are using previous version of linux
> 	as the reference.

the Linux behavior was always broken, and surprising for applications
like MTAs that expect the Solaris implementation of noac.  most NFS
client implementations follow the Solaris implementation, and most
applications that are NFS-aware expect noac to work the way it
now does on Linux.  Linux runs more than just a small set of Linux-
specific applications these days, remember.  i can't think of any
one, off hand, who uses noac the way you do (not that it's wrong,
just unique).

> 	The real bug it there is no documentation on any of the recent
> 	changes, the man pages are completly useless, and horribly
> 	out of date.    Attribute caching was previously described as
> 	attributes, and then changed to be the same as
> 	Sun's definition of all caching, somewhat of a major change,
> 	with no documentation changes.

no argument from me.  there is no good way for the documentation to
keep up with the rate that the Linux kernel changes.  that's the
challenge of Linus' philosophy of constant release.  it is up to
Linux distributors to check that the documentation matches the
feature set of the things they include in their distributions.

besides, when was the last time you found that documentation matched
implementation 100% on any operating system?

>     None of the man pages say
> 	anything aboue disabling *ALL* caching, and putting the client
> 	into sync mode.

again, the "noac" option does not disable data caching on either
Solaris or Linux.  it merely disables *write* caching, which is
different.

>     And mount does not scream about
> 	noac and async being non-compatible.

arguable.  there are plenty of combinations of mount options that are
inadvisable or ineffective.  here's a good one:

  mount -o soft,udp,rsize=1024,wsize=1024,timeo=2

another good one:

  mount -o tcp,timeo=1

here's an interesting case that neither works nor complains:

  mount -t nfs -o tcp
  mount -t nfs -o udp,remount

or how about this, which isn't dangerous, but has no effect:

  mount -t nfs -o noatime

is mount supposed to know about all combinations for all file systems,
and make sure you never make a mistake?  perhaps better checking can
and should be added to the NFS client over time.  and maybe even the
combination of "noac,async" should be made to work as you expect.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Robert G. Brown" <rgb@phy.duke.edu>
Subject: Re: network storage solutions
Date: Fri, 16 May 2003 09:21:50 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0305160800430.2959-100000@lilith.rgb.private.net>
References: <3EC3D895.2050008@bellsouth.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: beowulf@beowulf.org, Josip Loncaric <josip@lanl.gov>,
	<nfs@lists.sourceforge.net>, <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2] ident=[XODRllgtjyBNYCPReR7H/aRfJQt2LISv])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Gf9m-0003Cr-00
	for <nfs@lists.sourceforge.net>; Fri, 16 May 2003 06:21:54 -0700
To: "Jeffrey B. Layton" <laytonjb@bellsouth.net>
In-Reply-To: <3EC3D895.2050008@bellsouth.net>
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

On Thu, 15 May 2003, Jeffrey B. Layton wrote:

> > We've had similar problems while I was at ICASE.  "Hard" mounts would 
> > lock up client processes (even unmount) when the NFS server went down, 
> > but "soft" mounts were "too soft" for some of our users.  A reasonable 
> > solution is to "harden" your soft mounts by insisting on longer major 
> > timeouts, as in "retrans=15" (the default is 3). 
> 
> 
> I still think this is dangerous. With soft mounts you can
> still get silent data corruption despite the longer timeouts.
> Chuck, do you agree?
> 
> Jeff

Perhaps it is a question of probability, and what people are willing to
accept in terms of data loss in a given environment.  It is a
cost-benefit equation, as always, so acceptable solutions do have to at
least examine the cost of a corrupted file against other costs
associated with using hard mounts everywhere.  

In one somewhat jaded view, one says "crashes happen, and if a crash
occurs in the middle of a file write there is a distinct chance of
losing that file".  This is (I suspect) true anyway for both hard and
soft mounts, depending on the cause of the crash and what has to be done
to fix it.  If the exported filesystem is left in an inconsistent state
post-crash and is modified before being re-exported to the clients, they
are likely to see a stale mount and not be able to complete the ongoing
write transaction.

Nowadays (within linux) it is indeed pretty rare as Greg noted for a
client not to recover gracefully from a server crash and reboot,
although I confess to being less lucky -- we still see stale NFS mounts
after certain crashes, and generally plan on being ABLE to reboot all
the clients in the department after any major, planned downtime of our
principle servers.  There seems to be a bit of state dependence here --
"most" clients recover, but one or two sometimes seem to hang and need
either a therapeutic reboot or at least a remount to clear some
state-dependent problem.

A question for the experts out there -- does the use of a journalling
filesystem affect the probability of NFS file corruption on a soft
mount?  As in, is there any interaction between the journal and the NFS
server that cause an incomplete or corrupted transaction to be
interpreted as cause for invoking some of the protections journalling
provides?  I'm just curious...one would think that NFS would effectively
"journal" itself to consistently end up in a "reliable" state (which
might well cost one the latest writes to the file!) even on a soft
mount.

The probability and cost-benefit issues are often related to LAN
architecture.  In a common architecture, one has a single (or perhaps
2-3) "major server(s)" that have lots of capacity in all dimensions.
This is where users manipulate "critical data" (e.g. home directories,
project directories), and one EXPECTS the LAN to effectively go down
when these servers are down so the mounts should definitely be hard
mounts (although they might well be automounts, so your system isn't
hung if YOUR home directory server stays up).  To protect against
anomalous amounts of downtime (which DEFINITELY costs one work at a
fixed rate, compared to the stochastic expectation of loss in the case
of possible data corruption) one makes the servers as reliable as
possible -- they are architected "not to go down" and have things like
four-hour service or hot mirror spares.

In a few cases, as in Greg's example, lots of people with desktop
workstations export workspace and crossmount it all over the place.
Then the issue becomes one of cumulative stability of the workstation
space.  Because of the nasty behaviors of e.g. stat, it is quite common
for a system or at least a session to effectively hang when ANY of its
hard mounts go down -- perhaps not to crash, and to recover gracefully
when the offending server comes back up, but in the meantime you can
lose access to your workstation and ability to do work -- a real cost,
potentially multiplied by N on a big network where NOBODY gets to do
work until the workstation is back up.  The downed workstation might NOT
be so reliable and might NOT have hot and cold running service and might
stay down a day or more, and a decision might well be made to take
draconian measures to free up the (not really) "hung" clients.  This
also can cost work, e.g. work in progress, where a user may have to
choose between not being able to work interactively while their
background task completes or e.g. killing the background task with a
reboot to come back up without the hung mount.

Obviously the "best" solution to this sort of situation is to not put
NFS exports on your path where you can avoid it, and to use the
automounter to effectively reduce the number of mounts that can hang on
a general path stat or df to the unavoidable main (hopefully reliable)
filesystems plus those exported spaces belonging to your buddies that
you actually are using NOW.  However, in a small/informal LAN (like a
home network), where the workstations that are providing the mounts
aren't horribly overloaded at either the network or CPU or memory level
(so they aren't at all likely to timeout on an NFS request) and where
the admin either doesn't want to figure out the automounter or just
isn't that concerned about the (low) probability of data corruption, one
might choose as a "quick and dirty" solution to use a soft mount and bet
that data corruption never occurs.

Back a LONG time ago when NFS recovery on a hard mount was basically
nonexistent (e.g. SunOS, Irix, etc.) I used sometimes used soft mounts
on crossmounted workstation spaces and our (much slower, much less
powerful client "servers") LAN never knowingly had a problem with data
actually being corrupted -- although files were sometimes lost, leaving
one of those lovely .nfs323112114 tags -- so I'd guess that the
>>probability<< of silent corruption is actually pretty low.  On the
other hand, even a soft mount was never really all that recoverable
either -- NFS just plain had a way of stubbornly hanging whenever a
server went down, no matter what.

It proved smarter, more cost-beneficial, and more professional in the
long run (in a production LAN environment, with real costs associated
with EVERYTHING) to consolidate exported space, including e.g. project
space, into a very few, very reliable servers, period and just not LET
"everybody mount everybody else", soft OR hard.  Um, so to speak;-) I AM
talking about networking here, after all...

In summary, while soft mounts exist(ed) "for a reason", they never in
the past and still don't work terribly well or reliably, and the reasons
themselves for using them have mostly passed on.  There are better ways
to cope with the cost/benefit dilemna between de facto hung workstations
and possibly lost/corrupt data.  The vast improvements in automounters
(which back in those same old days sucked incredibly and were as likely
to produce problems as to solve them:-) make automounters with hard
mounts, from a few, reliable, consolidated servers, by far the
preferrable solution to the problem.  The fact is that most users of
single user workstations are most unlikely to have more than one or two
automount directories mounted at any one time (within the mount timeout
window) simply because they will typically be "working" at one path
location or perhaps two at a time.

Server consolidation also makes it MUCH easier to back things up,
another "chronic" problem in cowboy networks where there otherwise would
be project directories on fifty workstations, most of them with
relatively unreliable IDE disks, every one being used by somebody that
would whine or bluster and threaten if their data went away upon the
crash of their cheap, three year old disk.  Then there are the "control
and security issues" -- NFS is a bleeding wound as far as security is
concerned anyway (or at least has been historically) and all those
crossmounts on private workstations offer a cracker or evil employee
numerous opportunities to be naughty.  True, one generally keeps a
sucker rod handy to school the latter, but cleaning it afterwards is
such a mess.  Workstations just aren't architected (without effort and
additional expense) to be good, secure, reliable servers in a LAN
serving hundreds of clients.

The "best" solution for "most" LAN architectures is thus to automount
basically everything but the home directories or other "critical"
filesystems mounted from a few reliable servers -- maybe even automount
the home directories (if you have more than one home server, e.g.)!
That way a desktop client system doesn't (generally) "hang"
(recoverably, but hang nonetheless as far as the user is concerned) or
become otherwise difficult to work with if a non-critical or currently
unused server dies -- at most one might lose a tty window when one tries
to access an automount, but if one keeps the automounts off of one's
path then the path stat won't hang (almost) every shell transaction.
Administrative control is concentrated in a relatively few points of
failure and systems to secure and back up.  Data reliability and
protection against loss of work time and access at the same time.

   rgb

-- 
Robert G. Brown	                       http://www.phy.duke.edu/~rgb/
Duke University Dept. of Physics, Box 90305
Durham, N.C. 27708-0305
Phone: 1-919-660-2567  Fax: 919-660-2525     email:rgb@phy.duke.edu





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

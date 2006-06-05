From: Neil Brown <neilb@suse.de>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Mon, 5 Jun 2006 13:13:10 +1000
Message-ID: <17539.41286.81087.480257@cse.unsw.edu.au>
References: <20060601155929.GA890@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fn5X5-0000LM-Ke
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 20:13:35 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fn5X5-0000Ty-6O
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 20:13:35 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fn5X4-0008QX-ER
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 20:13:35 -0700
To: "Steinar H. Gunderson" <sesse@debian.org>
In-Reply-To: message from Steinar H. Gunderson on Thursday June 1
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday June 1, sesse@debian.org wrote:
> (Please Cc me on any followups, I'm not subscribed to the list)
> 
> Hi,
> 
> I've been doing some work on the Debian packages of nfs-utils lately; as soon
> as libgssapi and librpcsecgss goes in we should be ready to push in 1.0.8
> (yes, about time :-) ), so I thought it would be time to push some of the
> changes from Debian back upstream. (I'm sorry this didn't happen before the
> 1.0.8 release, but it should at least reach 1.0.9.) In addition, there are
> several things that would make the task of maintaining the Debian packages
> easier:

Thanks for this.

> 
>  - Please just remove the debian/ directory from CVS; it looks like the
>    previous maintainer preferred to maintain the packaging in there, but now
>    it is primarily a burden. (The 1.0.7 packaging ended up resorting to ugly
>    hacks to work around it; the 1.0.8 packaging simply has it removed from
>    the upstream tarball.)

I have no problem doing this.  debian/ will be gone in 1.0.9.

Note that I've given up on CVS (for now at least) and have decided to
try using 'git' for nfs-utils maintenance.  It should appear on
  linux-nfs.org
at some stage (once I am happy that I know what I am doing with it).


>  - It would be helpful if you could run autogen.sh before shipping the
>    tarballs; AFAIK this is normal practice in most other packages, and it
>    eliminates the need for us to do it ourselves. (The 1.0.7 packaging ran
>    autoconf as a part of the build process, but this turned out quite ugly in
>    a number of places. The 1.0.8 packaging has autogen.sh run before the
>    Debian diff is created, which is better but creates a huge Debian diff.)

Yes, I'll make sure that happen (I'm still getting used to how all
these auto-tools work!).


> 
> So, over to the patches -- they are all against 1.0.8, and can be found at
> http://people.debian.org/~sesse/nfs-utils-patches/ :
> 
>  - fix_exportfs_with_multiple_matches.diff: Fixes a problem with exportfs -o
>    and multiple entries of the same type for the same patch that matches
>    a given client. The entire rationale and problem description can be found
>    at http://bugs.debian.org/245449 -- this is also in the SourceForge
>    tracker as #940556
>    (http://sourceforge.net/tracker/index.php?func=detail&aid=940556&group_id=14&atid=100014).

This look sane - thanks.
I wonder if there is a way to turn off the request tracker - no-one
looks at it...


>  - fix_anonuid_and_anongid.diff: The current code uses -2 for default
>    anonymous uid and gid, in the hope that it will be equivalent to 65534.
>    However, on systems with 32-bit uids and gids, this returns another value
>    entirely, which gives rise to an unpredictable default uid and gid (which
>    probably doesn't match what's in passwd and group). This patch fixes the
>    code and documentation to use 65534 explicitly instead.

I've noticing this problem before and always shied away from it.
While the value might be "unpredictable", someone might be depending
on the current behaviour, and changing it could break things for some
people while fixing things for others...
Can you -- or anyone else -- convince me that this is really a good
and safe thing to do?  I'm fairly open to being convince, but I don't
feel I'm familiar enough with all the issues and would love to hear
from someone who is.
My particular concern is "What might it break, and how much of a
problem could that be?" 

>  - escape_hashes_in_exports.diff: Makes sure any # signs in the printed-out
>    exports file are escaped (as with quotes, spaces, etc.), so they won't be
>    treated as a comment when they're read back in again.

Hmm... I think the real bug here is that a '#' is treated as starting
a comment even if it isn't at the start of a word.
xgetc shouldn't check for '#', xgettok should.
The kernel doesn't currently escape '#' in /proc/fs/nfs/exports so
reading pathnames containing '#' from there will still be a problem.

So I might fix that too..... could that break anything?


>  - document_sync_option.diff: Document the 'sync' option in the exports(5)
>    man page -- ATM only the 'async' option is documented, which is not very
>    symmetric. :-)

Ok, thanks.

>  - mountd_state_directory.diff: Let the user select (via a new parameter)
>    the path to the NFS state directory for mountd, to match the statd
>    functionality. (If you take it in, you might want to remove the part in
>    the manpage saying it's Debian-specific.)

Seems pretty pointless ;-)  but that won't stop be accepting it...

I bet you didn't test the '-s' usage :-)  I've fixed that.

I love getting patches that also update the man page!  Now if I can
only train people to update ChangeLog too :-)


>  - fix_nhfsrun_signal.diff: nhfsrun is supposed to be able to be signalled
>    with SIGUSR1, but the signal trapped is number 30, which is something
>    else entirely (SIGPWR). This patch simply changes it to say "USR1", which
>    gets it right no matter what the value is.
> 

Simple enough, thanks.

> I added a new one:
> 
>  - fix_manpage_errors.diff: Fixes a few errors from man in the idmapd.conf
>    man page. (I don't know of any other man pages giving errors; "man -l
>    foo.man >/dev/null" is usually the simplest way to check for these.)

Hmmm. I'm not sure I like removing blank lines just for the same of
some silly warning - blank lines are good for readability.
I have instead replaced them with a single ' which removes the warning
and is almost as good as a blank.

You can see all these patches via
  git clone git://linux-nfs.org/~neilb/exports/nfs-utils

I'll try to organise for it to just be
  git clone git://linux-nfs.org/nfs-utils

Thanks again,
NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

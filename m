From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Re: Linux 2.2 client trouble after 2.4.18 server reboot
Date: Tue, 13 Aug 2002 09:14:43 +0930 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208122344.g7CNihM19972@sprite.physics.adelaide.edu.au>
References: <3D451F23.92E4DA72@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jwoithe@physics.adelaide.edu.au (Jonathan Woithe),
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eOrp-00012J-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 16:44:57 -0700
To: james-p@moving-picture.com (James Pearson)
In-Reply-To: <3D451F23.92E4DA72@moving-picture.com> from "James Pearson" at Jul 29, 2002 11:55:31 AM
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi all

I have finally managed to track down what appears to have caused this
problem.  In short, the list of currently exported volumes used machine
names to identify which machines had an active mount at the time the machine
was shut down.  During boot (under Slackware 8.1 at least), NFS was started
before our local named server, which meant that the machine names didn't
resolve at the time the NFS server was started.  It seems that when this
occurs the NFS system doesn't retry the name resolution at a later time at
all.  Because the names don't resolve, it seems the NFS server decides to
make these prior mounts inaccessible.  The situation can be fixed by doing
a re-export following the start of named.

As far as I can see there's no reason why the nfs system has to start before
named (and NIS/LDAP for that matter).  If it was started after, it would
ensure that name mapping was definitely available when NFS started and so
prior mounts will be resumed without trouble.  On our server I have moved
NFS startup to after named with no ill-effects.  Is there any reason not to
do this routinely?

Regards
  jonathan

James Pearson wrote:
> Have a look through the archives of this list at:
> 
>  http://marc.theaimsgroup.com/?l=linux-nfs&r=1&w=2
> 
> It could be similar to the problem reported in thread:
> 
>  http://marc.theaimsgroup.com/?l=linux-nfs&m=101796943306978&w=2

> Jonathan Woithe wrote:
> > 
> > Hi all
> > 
> > [Please CC me replies since I'm not subscribed to this list]
> > 
> > Recently I upgraded our NFS server to Linux 2.4.18.  This server provides
> > exported home directories for our user Linux boxes which are currently
> > running 2.2.19.
> > 
> > Most of the time everything seems to be going well.  However, if the server
> > is rebooted the clients seem unable to restore the NFS connection to a
> > usable state.  The logs note the server becoming unavailable and then
> > following the reboot they note that the server is now "ok".  However, any
> > attempt to then access the mounted volumes is greeted with a "permission
> > denied" error.  Even root can't access the drives.
> > 
> > If the NFS volumes are unmounted and remounted the problem (predictably)
> > goes away.  Of course such an unmount can't occur until people have logged
> > off, which makes it a little cumbersome.
> > 
> > The exported directory on the server is a ReiserFS filesystem, exported with
> > only "rw" options.  The client mounts with "hard,intr,bg" options.  NFSv3
> > support is not compiled in on the 2.2.19 clients.  The server is a default
> > slackware configuration (from the point of view of NFS):
> >   CONFIG_NFS_FS=y
> >   CONFIG_NFS_V3=y
> >   # CONFIG_ROOT_NFS is not set
> >   CONFIG_NFSD=m
> >   CONFIG_NFSD_V3=y
> >   CONFIG_SUNRPC=y
> >   CONFIG_LOCKD=y
> >   CONFIG_LOCKD_V4=y
> > The server also has the lockd oops fix from Trond.
> > 
> > I would appreciate any pointers to ways to stop this from happening.
> > Requiring that all users log out before a server reboot is rather
> > inconvenient.

-- 
* Jonathan Woithe    jwoithe@physics.adelaide.edu.au                        *
*                    http://www.physics.adelaide.edu.au/~jwoithe            *
***-----------------------------------------------------------------------***
** "Time is an illusion; lunchtime doubly so"                              **
*  "...you wouldn't recognize a subtle plan if it painted itself purple and *
*   danced naked on a harpsichord singing 'subtle plans are here again'"    *


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

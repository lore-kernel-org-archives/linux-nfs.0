From: Neil Brown <neilb@suse.de>
Subject: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Fri, 16 Mar 2007 19:00:21 +1100
Message-ID: <17914.20117.186786.830574@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Steve Dickson <SteveD@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS7MV-0002rQ-Ad
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 01:00:31 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HS7MV-00039h-QR
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 01:00:33 -0700
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


I'm keen on getting to nfs-utils-1.1.0 relatively soon and so have
been pushing towards it.

To this end I have picked though the patches in current RPMs from SuSE
and Redhat and the deb from Debian.
With few exceptions, everything I have not taken are either
distro-specific or - in my opinion - wrong (or at least imperfect).

A particular exception is fixes for mount.nfs w.r.t. handing of
MS_REMOUNT.  I haven't figured out what that is all about yet and it
is getting late. :-)

If anyone has anything else outstanding that is not in the git, please
consider at least telling me about it.

One thing I have been putting thought into is improvements for statd.
Current SLES releases have statd in the kernel and I don't want to
continue that, but instead want to make sure that user-space statd
provides at least equally good service...

I have changed the default so that statd now compiled with
RESTRICTED_STATD, so that it only listens to locked for monitor
requests.  Everyone else is ignored.  There is no-one else who uses
statd anywhere, so this should be perfectly safe and is more secure.

I have also arranged that the new "mount.nfs" will try to start statd
if that seems to be appropriate (via a script so statd options can be
specified).  Said script is not currently in .git, but
cat > /usr/sbin/start-statd <<END
!#/bin/sh
PATH=/sbin:/usr/sbin
statd
END
chmod +x /usr/sbin/start-statd

should do it.  Comments in this idea and approach are welcome.

Statd currently does several very different things.
1/ It listens for monitor requests from lockd and creates
   files in /var/lib/nfs/sm/HOST
2/ It listens for notifications from peers and tells lockd
   that those peers have restarted.
3/ It moves files from sm/ to sm.bak/ and then tries to 
   notify every host listed in sm.bak/

The first is very similar to what NFSv4 needs for state management,
though is somewhat simpler.  I would like to create a better
interface for the kernel to ask for state to be stored, and then use
if for NFSv4 and NLM, subsuming this function.

The second is very simple and could reasonably be moved into the
kernel.

The last is a totally independent operation that just needs to run at
boot time until everything is notified and then exit.

I would like to:

A/ create a separate program "statd-notify" that just performs
  operation 3.  It is always run at boot time, but often exits
  very soon.  When statd starts it possibly forks and runs 
  "statd-notify" depending on options.  
  Then all that code can be removed from statd.
  Redhat currently has a patch that move drop_privs a little later,
  presumable related to getting statd-notify functionality
  configured properly (hard to be sure - no comments in the patch).

B/ Add functionality to the kernel to register and listen to statd
   'notify' requests and act upon them immediately.  This would have
   to default to off and only be enabled if a new nfs-utils requested
   it.

C/ Create an "record state" mechanism that suits NFSv4 and NLM,
   incorporate the user-space side of this into statd and have statd
   detect if the kernel is new enough and, if it is, tell the kernel
   to listen for statd-notify requests, and itself listen to the
   kernel for state-storage requests.

I don't know if all of this will be ready for 1.1.0, but I would like
to have 'A' done at least.

Comments or questions on this are also quite welcome.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

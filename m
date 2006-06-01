From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Fusing Debian patches back into nfs-utils
Date: Thu, 1 Jun 2006 17:59:29 +0200
Message-ID: <20060601155929.GA890@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlpaH-0004JJ-M3
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:59:41 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FlpaG-0007DY-5y
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:59:41 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50)
	id 1FlpZx-0001Oy-3v
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 17:59:24 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1Flpa5-0000Hu-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 17:59:29 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

(Please Cc me on any followups, I'm not subscribed to the list)

Hi,

I've been doing some work on the Debian packages of nfs-utils lately; as soon
as libgssapi and librpcsecgss goes in we should be ready to push in 1.0.8
(yes, about time :-) ), so I thought it would be time to push some of the
changes from Debian back upstream. (I'm sorry this didn't happen before the
1.0.8 release, but it should at least reach 1.0.9.) In addition, there are
several things that would make the task of maintaining the Debian packages
easier:

 - Please just remove the debian/ directory from CVS; it looks like the
   previous maintainer preferred to maintain the packaging in there, but now
   it is primarily a burden. (The 1.0.7 packaging ended up resorting to ugly
   hacks to work around it; the 1.0.8 packaging simply has it removed from
   the upstream tarball.)
 - It would be helpful if you could run autogen.sh before shipping the
   tarballs; AFAIK this is normal practice in most other packages, and it
   eliminates the need for us to do it ourselves. (The 1.0.7 packaging ran
   autoconf as a part of the build process, but this turned out quite ugly in
   a number of places. The 1.0.8 packaging has autogen.sh run before the
   Debian diff is created, which is better but creates a huge Debian diff.)

So, over to the patches -- they are all against 1.0.8, and can be found at
http://people.debian.org/~sesse/nfs-utils-patches/ :

 - fix_exportfs_with_multiple_matches.diff: Fixes a problem with exportfs -o
   and multiple entries of the same type for the same patch that matches
   a given client. The entire rationale and problem description can be found
   at http://bugs.debian.org/245449 -- this is also in the SourceForge
   tracker as #940556
   (http://sourceforge.net/tracker/index.php?func=detail&aid=940556&group_id=14&atid=100014).
 - fix_anonuid_and_anongid.diff: The current code uses -2 for default
   anonymous uid and gid, in the hope that it will be equivalent to 65534.
   However, on systems with 32-bit uids and gids, this returns another value
   entirely, which gives rise to an unpredictable default uid and gid (which
   probably doesn't match what's in passwd and group). This patch fixes the
   code and documentation to use 65534 explicitly instead.
 - escape_hashes_in_exports.diff: Makes sure any # signs in the printed-out
   exports file are escaped (as with quotes, spaces, etc.), so they won't be
   treated as a comment when they're read back in again.
 - document_sync_option.diff: Document the 'sync' option in the exports(5)
   man page -- ATM only the 'async' option is documented, which is not very
   symmetric. :-)
 - mountd_state_directory.diff: Let the user select (via a new parameter)
   the path to the NFS state directory for mountd, to match the statd
   functionality. (If you take it in, you might want to remove the part in
   the manpage saying it's Debian-specific.)
 - fix_nhfsrun_signal.diff: nhfsrun is supposed to be able to be signalled
   with SIGUSR1, but the signal trapped is number 30, which is something
   else entirely (SIGPWR). This patch simply changes it to say "USR1", which
   gets it right no matter what the value is.

Let me know if you have questions about these patches, or really anything
else; I'm not the Debian maintainer, but I seem to be quite involved with the
packaging right now, so I guess I could at least point you the right place. :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

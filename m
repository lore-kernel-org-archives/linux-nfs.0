From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Thu, 5 Aug 2004 15:26:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040805052619.GT5581@sgi.com>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com> <20040713151759.GC3023@fieldses.org> <20040802103905.GI25023@suse.de> <20040804201411.GL19282@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bsaly-0000Ge-KU
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 22:26:38 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bsalx-0002Zn-Al
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 22:26:37 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040804201411.GL19282@fieldses.org>
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

On Wed, Aug 04, 2004 at 04:14:11PM -0400, J. Bruce Fields wrote:
> On Mon, Aug 02, 2004 at 12:39:05PM +0200, Olaf Kirch wrote:
> > On Tue, Jul 13, 2004 at 11:17:59AM -0400, J. Bruce Fields wrote:
> > But it sucks. I had folks run something like 12-15 performance
> > measurements and take the NFS stats, and it was a huge mess to sort
> > through.  Telling folks "use nfsstat -z to wipe stats before each
> > command" is much easier.
> 
> Well, like I say, we could implement "nfsstat -z" by checkpointing as
> above but just writing to a file at some default path, though admittedly
> the choice of path might not be obvious.

FWIW, futzing with zeroing or checkpointing should not be necessary
on Altix systems because they ship with PCP, a stats gathering
package which samples the NFS stats (among many others) and does
rate conversion.

http://oss.sgi.com/projects/pcp/

> Having nfsstat just hang around till it's signaled (like tcpdump does)
> would also be easy.

IRIX' nfsstat has a -C option which uses curses to display every 1
sec the rates of various NFS stats, until interrupted.  It's a bit
like "watch nfsstat" but shows rate converted numbers instead of
changing counters.  Here's an example screen, for a machine getting
30 RPC calls/sec:



 4: Server   snort    Aug  5 15:21:21                           D: Delta/second

Server RPC:
calls      badcalls   nullrecv   badlen     xdrcall    duphits    dupage
30         0          0          0          0          0          40086.17

Server NFS V3:
calls        badcalls
30           0
null         getattr      setattr      lookup       access       readlink
1  0%        10 33%       1  2%        16 52%       1  0%        0  0%
read         write        create       mkdir        symlink      mknod
2  4%        1  3%        0  0%        0  0%        0  0%        0  0%
remove       rmdir        rename       link         readdir      readdir+
0  0%        0  0%        0  0%        0  0%        0  0%        0  0%
fsstat       fsinfo       pathconf     commit
1  1%        0  0%        0  0%        1  2%  

1: Client[V2]  2: Server[V2]  3: Client[V3]  4: Server[V3] 5: Daemons  DZR:mode



Something like that might be more useful than the -z option.


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

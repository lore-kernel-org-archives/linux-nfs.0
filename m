From: Christian Reis <kiko@async.com.br>
Subject: lockd shutdown/umount order
Date: Tue, 28 Jan 2003 15:05:24 -0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030128150524.E11078@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


As the final cleanup of the diskless shutdown sequence, I would like to
know what procedure is the correct one for an NFS-root workstation.
Currently, the following set of steps happens:

    1. killall5 murders rpc.statd and portmap
    2. umount -tnfs -a -r runs
    3. the kernel complains: 
        lockd_down: lockd failed to exit, clearing pid
    4. halt goes on without a problem.
    5. lockd complains: failed to unmonitor 192.168.99.4 *after halt*

(I never knew kernel threads could complain after halt, amazing)

Now seeing this, I have patched killall5 to allow specifying certain
pids for exclusion from the kill list, and I am contemplating *not*
killing statd and portmap. However, I'm not sure if this is the correct
approach. I see the following options:

    - Ignore the lockd_down and the failed to unmonitor messages. Are
      they safely ignored, and can they be worked around or disabled in
      that case?

    - Make killall5 not murder rpc.statd/portmap. However, doesn't this
      mean that they will be left "hanging" from the filesystem point of
      view? Remember that /var/lib/nfs is *also* hosted on the server.

    - Change something else in the shutdown order to make it right (I
      can't really see how).

I see that other users have had similar problems:
http://fscked.org/writings/clusters/halt.patch alters the shutdown to
not run killall5 at all, which is not a good solution IMHO since
processes can stay running and block other umounts (and never have a
chance to die cleanly AAR).

Has anyone <wink> ran into this problem, and found a solution?

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

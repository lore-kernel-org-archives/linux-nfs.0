From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/7] fix setuid/setgid clearing in networked
	filesystems (rev 7)
Date: Thu, 20 Sep 2007 05:10:35 -0400
Message-ID: <200709200910.l8K9AZId001323@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org,
	ecryptfs-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patchset is the 7th revision for fixing the clearing of setuid and
setgid bits in networked filesystems. It should apply cleanly to
2.6.23-rc6-mm1.

The first four patches in the set are cleanup patches to make sure that
those filesystems don't trip the new BUG() call in notify_change. The
fifth patch (the main one) fixes notify_change to not clear the
ATTR_KILL_S*ID bits when interpreting them into a mode change. The final
two patches change NFS and CIFS to take advantage of the new scheme.

This is basically the same patchset as version 6. The main differences
are changes to ecryptfs and unionfs patches to accomodate changes made
in recent -mm patches. Also, when I sent out the 6th revision I forgot
to mention that the knfsd patch had been changed to more closely reflect
the existing behavior when receiving a setattr call that changes the
mode and uid/gid.

This patchset is being submitted for inclusion into -mm.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

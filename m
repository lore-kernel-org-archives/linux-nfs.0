From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: 8 patches cleaning up nfsd initialization
Date: Thu, 15 Nov 2007 16:56:55 -0500
Message-ID: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

While working on something unrelated I noticed nfsd tends to ignore a
lot of memory allocation failures on initialization.  I don't think
we'eve seen a bug report here--such failures are probably nearly
nonexistant.  But still it seems a minor bug in most cases not to catch
such failures.

My guess is that one of the motivations for the current behavior, in the
case of failures to create /proc entries, was to continue to allow nfsd
to function in kernels with no proc support whatsoever.

However in kernels that do have proc support failure to create such
entries should be treated as fatal.  So, I add some #ifdef's to handle
this case explicitly.

I also add "select PROC_FS" when nfsv4 or gss are selected, since those
newer features don't function at all without proc.

Look reasonable?

--b.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

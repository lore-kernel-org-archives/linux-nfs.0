From: Steve Dickson <SteveD@redhat.com>
Subject: Last call for nfs-utils patches
Date: Tue, 04 Mar 2008 10:17:31 -0500
Message-ID: <47CD680B.1070106@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070308070304070709040505"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070308070304070709040505
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


I'm planning on cutting a nfs-utils-1.1.2 release since
there has been a number commits since the last 1.1.1 release.

The attached list are all of the commits that have been made to
the git://linux-nfs.org/nfs-utils git tree.

(Note: to get a working copy of this tree use:
    git clone  git://linux-nfs.org/nfs-utils nfs-utils)

So if you don't see a commit you have posted to either
the nfs or nfsv4 mailing list it probably means I missed it
so you might want to bring it to my attention. 
(Please Note, the patch authors in some of my earlier
commit are incorrect. This was simply due to my lack
of git knowledge. Once it was pointed it out to me,
the problem was corrected.)

Also if you were holding off posting some (hopefully)
non-intrusive patches now it the time. There is a very 
good chance I will not cut the release until this weekend.

tia,

steved.





--------------070308070304070709040505
Content-Type: text/x-log;
 name="git.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="git.log"

commit f24884196dac4cffc3ae79cf87cf51d892cda46c
Author: Neil Brown <neilb@suse.de>
Date:   Tue Mar 4 09:39:31 2008 -0500

    Stop the kernel export table from being flushed
    on MIPS machines.
    
    Reported-by: Anirban Sinha <ASinha@zeugmasystems.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d15fa02fe38f6f1c9183540810ac7bfeac0c7c17
Author: Drew Middlesworth <drew.middlesworth@gmail.com>
Date:   Tue Mar 4 09:27:57 2008 -0500

    Increase the number of concurrent krb5 mounts by increasing
    the size of the poll array
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bcd0fcaf0966c546da5043be700587f73174ae25
Author: NeilBrown <neilb@suse.de>
Date:   Tue Feb 26 13:57:39 2008 -0500

    If validateascii is passed a string containing only non-zero 7bit
    values, then the loop with exit with i == len, and the following
    test will access beyond the end of the array.
    
    So add an extra test to fix this.
    
    Found by Marcus Meissner <meissner@novell.com>.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit acf95d32a44fd8357c24e8a04ec53fc6900bfc58
Author: Peng Haitao <penght@cn.fujitsu.com>
Date:   Tue Feb 26 13:52:18 2008 -0500

    Fixed typo in the nfsstat command line arugments.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 46d439b17f22216ce8f9257a982c6ade5d1c5931
Author: Vince Busam <vbusam@google.com>
Date:   Tue Feb 26 13:04:52 2008 -0500

    Stop gssd from ignoring the machine credential cache
    defined by the -d flag
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

commit 9dd9b68c4c44f0d9102eb85ee2fa36a8b7f638e3
Author: Harshula Jayasuriya <harshula@sgi.com>
Date:   Tue Feb 12 16:13:25 2008 -0500

    In mountd, if get_exportlist() (utils/mountd/mountd.c) returns NULL it
    should not be considered a failure. It just means that there are no
    exports on the system.
    
    The practical problem with the current code is that a showmount -e
    results in a syslog message from mountd that looks like:
    
    rpc.mountd: export request from 10.250.100.2 failed.
    
    Reviewed-by: Greg Banks <gnb@sgi.com>
    Signed-off-by: Harshula Jayasuriya <harshula@sgi.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7a817c45eaeb6aa93fdb5ca4d81c363b4e4218f0
Author: Frank Filz <ffilzlnx@us.ibm.com>
Date:   Sat Feb 9 07:48:48 2008 -0500

    Cleaned up some typos that were found in the various
    places in the mountd code.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

commit b5651e42cedc2b91aba87ea30520884d7f43b36f
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Jan 24 17:02:08 2008 -0500

    Added in relatime mount option so mount.nfs stays
    compatible with the mount command in util-linux-ng
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2d77e3a27b7b211f303fcc3a813a044838dad970
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Jan 19 07:59:26 2008 -0500

    Fix bug when both crossmnt and fsid are set.
    
    When exported a filesystems with option inherited (by the crossmnt
    option) from a higherlevel filesystem, ignore filesystem specific
    options like FSID and explicit UUID.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 399cc3dad0cdfe8dca4a0ae9035a0554d7223eb2
Author: Steve Dickson <steved@dickson.boston.devel.redhat.com>
Date:   Thu Jan 17 11:25:37 2008 -0500

    Stop segfaults on amd64 during warnings messages by creating
    a second va_list in xlog_backend() and then use that va_list
    to print messages on stderr.
    
    Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
    Signed-off-by: Steve Langasek <vorlon@debian.org>
    Signed-off-by: Steve Dickson <steved@dickson.boston.devel.redhat.com>

commit 72ada109b86622db8009e774ebc96a7a92094e8a
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 12:01:13 2008 -0500

    The kernel doesn't support the underlying parts needed for changing the
    MNT program number.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 72bc295da78bafff92762b8afbb298ac16d1ff43
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 12:00:32 2008 -0500

    The kernel hasn't supported the underlying parts needed for changing the
    NFS program number for a very long time.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit abb00ff7cff3c6540978d9b463dee3d4fdda15f4
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 11:53:41 2008 -0500

    Address an inconsistency:  the mount.nfs command uses the glibc routines
    to manipulate /etc/mtab (setmntent) but, everything else in nfs-utils
    uses a local private version (nfs_setmntent).  The local version does
    some extra mangling of the mtab entries.
    
    We should check what util-linux does these days to be sure, but for now,
    let's make the mount.nfs command use the nfs_ variants of setmntent().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fa087f2dece4b1d322d951e9353e8ab93208194d
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 11:50:41 2008 -0500

    add_mtab() calls unlock_mtab() twice in one of its error exit paths.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0f3172012919d36e2a7e5bf46c388f8c028fc93e
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 11:48:23 2008 -0500

    When mount.nfs reports that statd isn't running, it suggests using the "-o
    nolocks" option, which doesn't exist.  It should say "-o nolock".
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ec637de16210c1c6fcb3a0df34d7889592f577dc
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 9 13:13:31 2008 -0500

    Automatically set 'nohide' on referral exports.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5c4f17a97b1260e9c564ddd9887afaf50a26de9d
Author: Steve Dickson <steved@dickson.boston.devel.redhat.com>
Date:   Wed Jan 9 11:51:41 2008 -0500

    Redress some nits in the description of the timeo option
    in the nfs(5) man page.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7c6a4ae0aff5c2cd5fde2909e8af886ccf0bd27d
Author: Steve Dickson <steved@dickson.boston.devel.redhat.com>
Date:   Mon Jan 7 10:39:37 2008 -0500

    Fixed typo in rpc.mountd's man page
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 46704243eb10718c722607cc7f66703e3eb3ac9c
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 4 10:26:21 2008 -0500

    Get rid of the "-i" option for mount.nfs[4] and always use the text-
    based mount(2) system call for kernel version 2.6.23 and later.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ca43d9d8c7bdbd067fb1fb4fa9d6e055f4d34ce5
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 4 09:27:35 2008 -0500

    Incorporated Chuck Lever's and Don Domingo's changes to the
    nfs(5) manual page.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Don Domingo <ddomingo@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bfdc26916d8dabd319240a3ce5198b6189040be7
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 10:40:36 2007 -0400

    When mountd gets a request to export a mountpoint which is not
    explicitly exported, but is below an export point that is flagged as
    "crossmnt", it passes the wrong path name to the kernel for the
      "filehandle -> directory"
    mapping.
    
    This can badly confuse the NFS client, and is certainly wrong.
    So use the correct path names.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 812a43c1e4e055ee684ab95b28b41f0c16cc52fd
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 10:36:36 2007 -0400

    When following a list of mount versions to probe -
    e.g. probe_mnt1_first or probe_mnt3_first - probe_both will first
    probe the appropriate NFS version and then, if that succeeds, probe
    the actual mount version.  However instead of probing the target mount
    version, it probes the "most appropriate" mount version for the given NFS version.
    This results in it probing:
      NFSv2, MOUNTv1
    twice rather than
      NFSv2, MOUNTv1
      NFSv2, MOUNTv2
    
    as would be more correct.
    
    This patch removes the "choose most correct" step and just use the
    current mouint version for the probe_vers array.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d4b159620b26dce8f83d41358d618ccc82fa82d4
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 09:35:05 2007 -0400

    This means that if mountd is run with "--no-nfs-version 3",
    It will first probe for NFS version 3, which will succeed (assuming the
    kernel supported NFSv3), then it will check the matching mountd version (3)
    and probe_port on discovering that isn't supported will try other versions,
    find "1" is supported will succeed.
    
    This leaves up using mount version 1 for an NFSv3 mount, which doesn't work
    and leads to a SIGSEGV
    
    There is no case where trying other versions is needed the request one is
    not supported, so simply remove that code.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit efbda485ff5b3d5916971e1af656d2c21307af30
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 09:14:57 2007 -0400

    The wording in the exportfs man page can be a bit confusing, implying
    that "exportfs -u :/foo" will unexport /foo from all hosts, which it won't.
    
    This patch cleans that wording up and adds a couple examples on how to
    unexport directories
    
    Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b1e64b99a97b27d850d7a615b291aa9aeb2972ab
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Oct 26 07:57:10 2007 -0400

    Added -S/--since to the nfsstat(1) manpage
    
    Author: David Richter <richterd@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>


--------------070308070304070709040505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------070308070304070709040505--

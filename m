From: Steve Dickson <SteveD@redhat.com>
Subject: nfs-utils-1.1.2 released.
Date: Mon, 24 Mar 2008 11:55:43 -0400
Message-ID: <47E7CEFF.9030205@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52302 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbYCXPzp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2008 11:55:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although it took a bit longer than expect, mainly do to
logistical reasons, the nfs-utils-1.1.2 maintenance release
is done. Its a available in all the usual places:

Git tree:    git://linux-nfs.org/nfs-utils
Tar ball:    http://www.kernel.org/pub/linux/utils/nfs/
SourceForge: http://sourceforge.net/projects/nfs

The release contains the following commits:
(Note there were a few patch submissions that did not 
make this release but they are queued for the next
release. Please check the git tree for recent commits)

commit d1e7ccccd9153d8cab1701a6396921ff7e57dd03
Author: Timo Aaltonen <tjaalton-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Date:   Thu Mar 13 13:02:32 2008 -0400


    Turn down gssd's syslog verbosity
    

    Modified-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit eed0765ee5a4b578d57672e22665b63db526b971
Author: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date:   Thu Mar 13 11:30:18 2008 -0400

    Stop rpc.mountd from probing all known devices which 
    causes idle disks to spin up for basically no reason.
    
    Signed-off-by: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ab26cd622e1a5ef22be2df1f3176158b1505df30
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Mar 11 13:11:50 2008 -0400

    Recently #include directives for autoconf's config.h 
    file were added in utils/mount/error.c and 
    utils/mount/mount.c, but appropriate HAVE_CONFIG_H
    checks were not added at the same time.
    
    In addition, several other .c files under utils/mount 
    reference autoconf-generated HAVE_ macros, but don't 
    appear to include config.h
    
    Also, Heinz-Ado Arnolds <arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org> 
    reports that this patch is needed to ensure START_STATD 
    is properly defined in utils/mount/network.c. Otherwise 
    start_statd() is always a no-op, even if the configure 
    script defines an appropriate statd start-up script.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Heinz-Ado Arnolds <arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9c1e19f1c6ba13e08c51c21db6f21ef1e203b37c
Author: Filipus Klutiero <chealer@gmail.com>
Date:   Tue Mar 11 12:52:26 2008 -0400

    Fixed typo in nfsd man page
    
    bz: http://bugzilla.linux-nfs.org/show_bug.cgi?id=160
    Signed-off-by: Filipus Klutiero <chealer@gmail.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bd04ddfc123625980e288dbef455e1170310b29a
Author: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date:   Mon Mar 10 15:20:36 2008 -0400

    Fixed a segfault in the mount.nfs command
    
    Signed-off-by: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b587496ba83ac7da31a33a0e1fd533773f3240ce
Author: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date:   Mon Mar 10 14:55:47 2008 -0400

    Fixed a couple typos that effected the '--mounts' 
    nfsstat option
    
    Signed-off-by: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0a4a2cba3a4f479c51f45fd66d761ffa4593e9e4
Author: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date:   Mon Mar 10 14:51:31 2008 -0400

    Fixed typo in gssd manpage
    
    Signed-off-by: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 00511ee5c97793fa8bf3f463ac07cbb4029ca149
Author: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date:   Mon Mar 10 14:49:31 2008 -0400

    The mount(5) man page states that the noquota, quota, 
    usrquota and grpquota options are ignored. (They are, 
    however, used by the quota tools, so having them in 
    fstab can be useful.) Make mount.nfs ignore
    them properly, matching the man page. There are a few 
    aliases (like usrjquota) that are parsed by quota, but 
    as these are not documented nor seem to be widely used, 
    they are not included.
    
    Signed-off-by: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8c947a43b6eb4ae1ab0c034e6ba6e8ec035b3505
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 10 14:42:21 2008 -0400

    Be explicit on how to update exports in the man page.
    
    Signed-off-by: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c4276d4353dc8dd26cc58ccbf4bf899999b84a57
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 5 10:07:11 2008 -0500

    As part of migrating from nfs-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org to 
    linux-nfs@vger.kernel.org, update the mailing list 
    address used to report bugs in nfs-utils.
    
    Removed the BUGS section in the mount.nfs and umount.nfs 
    man pages since they weren't consistent with the 
    contents of the BUGS sections in others in nfs-utils.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f24884196dac4cffc3ae79cf87cf51d892cda46c
Author: Neil Brown <neilb@suse.de>
Date:   Tue Mar 4 09:39:31 2008 -0500

    Stop the kernel export table from being flushed
    on MIPS machines.
    
    Reported-by: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d15fa02fe38f6f1c9183540810ac7bfeac0c7c17
Author: Drew Middlesworth <drew.middlesworth@gmail.com>
Date:   Tue Mar 4 09:27:57 2008 -0500

    Increase the number of concurrent krb5 mounts by 
    increasing the size of the poll array
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bcd0fcaf0966c546da5043be700587f73174ae25
Author: NeilBrown <neilb@suse.de>
Date:   Tue Feb 26 13:57:39 2008 -0500

    If validateascii is passed a string containing only 
    non-zero 7bit values, then the loop with exit with 
    i == len, and the following test will access beyond the 
    end of the array.
    
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

    In mountd, if get_exportlist() (utils/mountd/mountd.c) 
    returns NULL it should not be considered a failure. It 
    just means that there are no exports on the system.
    
    The practical problem with the current code is that a 
    showmount -e results in a syslog message from mountd 
    that looks like:
    
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
    
    When exported a filesystems with option inherited (by 
    the crossmnt option) from a higherlevel filesystem, 
    ignore filesystem specific options like FSID and 
    explicit UUID.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 399cc3dad0cdfe8dca4a0ae9035a0554d7223eb2
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Jan 17 11:25:37 2008 -0500

    Stop segfaults on amd64 during warnings messages by 
    creating a second va_list in xlog_backend() and then use 
    that va_list to print messages on stderr.
    
    Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
    Signed-off-by: Steve Langasek <vorlon@debian.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 72ada109b86622db8009e774ebc96a7a92094e8a
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 12:01:13 2008 -0500

    The kernel doesn't support the underlying parts needed 
    for changing the MNT program number.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 72bc295da78bafff92762b8afbb298ac16d1ff43
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 12:00:32 2008 -0500

    The kernel hasn't supported the underlying parts needed 
    for changing the NFS program number for a very long 
    time.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit abb00ff7cff3c6540978d9b463dee3d4fdda15f4
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 11:53:41 2008 -0500

    Address an inconsistency:  the mount.nfs command uses 
    the glibc routines to manipulate /etc/mtab (setmntent) 
    but, everything else in nfs-utils uses a local private 
    version (nfs_setmntent).  The local version does
    some extra mangling of the mtab entries.
    
    We should check what util-linux does these days to be 
    sure, but for now, let's make the mount.nfs command use 
    the nfs_ variants of setmntent().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fa087f2dece4b1d322d951e9353e8ab93208194d
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 11:50:41 2008 -0500

    add_mtab() calls unlock_mtab() twice in one of its error 
    exit paths.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0f3172012919d36e2a7e5bf46c388f8c028fc93e
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 16 11:48:23 2008 -0500

    When mount.nfs reports that statd isn't running, it 
    suggests using the "-o nolocks" option, which doesn't 
    exist.  It should say "-o nolock".
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ec637de16210c1c6fcb3a0df34d7889592f577dc
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 9 13:13:31 2008 -0500

    Automatically set 'nohide' on referral exports.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5c4f17a97b1260e9c564ddd9887afaf50a26de9d
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 9 11:51:41 2008 -0500

    Redress some nits in the description of the timeo option
    in the nfs(5) man page.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7c6a4ae0aff5c2cd5fde2909e8af886ccf0bd27d
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jan 7 10:39:37 2008 -0500

    Fixed typo in rpc.mountd's man page
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 46704243eb10718c722607cc7f66703e3eb3ac9c
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 4 10:26:21 2008 -0500

    Get rid of the "-i" option for mount.nfs[4] and always 
    use the text-based mount(2) system call for kernel 
    version 2.6.23 and later.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ca43d9d8c7bdbd067fb1fb4fa9d6e055f4d34ce5
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 4 09:27:35 2008 -0500

    Incorporated Chuck Lever's and Don Domingo's changes to 
    the nfs(5) manual page.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Don Domingo <ddomingo@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bfdc26916d8dabd319240a3ce5198b6189040be7
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 10:40:36 2007 -0400

    When mountd gets a request to export a mountpoint which 
    is not explicitly exported, but is below an export 
    point that is flagged as "crossmnt", it passes the 
    wrong path name to the kernel for the
    "filehandle -> directory" mapping.
    
    This can badly confuse the NFS client, and is certainly 
    wrong. So use the correct path names.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 812a43c1e4e055ee684ab95b28b41f0c16cc52fd
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 10:36:36 2007 -0400

    When following a list of mount versions to probe -
    e.g. probe_mnt1_first or probe_mnt3_first - probe_both 
    will first probe the appropriate NFS version and then, 
    if that succeeds, probe the actual mount version.  
    However instead of probing the target mount version, it 
    probes the "most appropriate" mount version for the 
    given NFS version. This results in it probing:
      NFSv2, MOUNTv1
    twice rather than
      NFSv2, MOUNTv1
      NFSv2, MOUNTv2
    
    as would be more correct.
    
    This patch removes the "choose most correct" step and 
    just use the current mouint version for the 
    probe_vers array.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d4b159620b26dce8f83d41358d618ccc82fa82d4
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 09:35:05 2007 -0400

    This means that if mountd is run with 
    "--no-nfs-version 3", It will first probe for NFS 
    version 3, which will succeed (assuming the
    kernel supported NFSv3), then it will check the matching 
    mountd version (3) and probe_port on discovering that 
    isn't supported will try other versions, find "1" is 
    supported will succeed.
    
    This leaves up using mount version 1 for an NFSv3 mount, 
    which doesn't work and leads to a SIGSEGV
    
    There is no case where trying other versions is needed 
    the request one is not supported, so simply remove 
    that code.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit efbda485ff5b3d5916971e1af656d2c21307af30
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 3 09:14:57 2007 -0400

    The wording in the exportfs man page can be a bit 
    confusing, implying that "exportfs -u :/foo" will 
    unexport /foo from all hosts, which it won't.
    
    This patch cleans that wording up and adds a couple 
    examples on how to unexport directories
    
    Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b1e64b99a97b27d850d7a615b291aa9aeb2972ab
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Oct 26 07:57:10 2007 -0400

    Added -S/--since to the nfsstat(1) manpage
    
    Author: David Richter <richterd@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>



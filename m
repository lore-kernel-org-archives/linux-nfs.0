From: "Sumanth Sukumar" <idli@myrealbox.com>
Subject: knfsd filehandle issues with active/passive failover servers
Date: Tue, 10 Sep 2002 12:02:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <01c101c258fc$94e454f0$8100000a@s8.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp-send.myrealbox.com ([192.108.102.143])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17oqHD-0003FL-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Sep 2002 12:02:19 -0700
To: "KNFSD Mailing List" <nfs@lists.sourceforge.net>
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

Hi all,
    I have a problem with the knfsd getting confused with certain
filehandles after a failover in an active/passive failover setup.
    The details of the setup are
    kernel: 2.4.19
    There are two servers, only one of which is active at any time. NFS
clients talk to the active box and when this box crashes, its IP is taken
over by the passive server, which starts nfsd and services the same clients.
These servers export a coda like filesystem through nfs. The underlying
filesystem is implemented as a kernel module that talks to a userspace
process via a pseudo device just like coda. The userspace fs process in turn
talks to other fileservers.The kernel module does *not* implement the nfsd
super_operations like dentry_to_fh and fh_to_dentry.

    Under the circumstances described above, I have nfs clients doing
operations on the first server when the failover is triggered and the
clients start talking to the newly active server. However, some of the time
I get the following errors in the syslog.

Aug 9 23:09:54 qa1gsp2-eth1 kernel: nfsd-fh: found a name that I didn't
expect: 2/7
Aug 29 23:09:54 qa1gsp2-eth1 kernel: nfsd-fh: found a name that I didn't
expect: 2/7
Aug 29 23:10:02 qa1gsp2-eth1 kernel: nfsd-fh: found a name that I didn't
expect: 3/8
Aug 29 23:10:02 qa1gsp2-eth1 kernel: nfsd-fh: found a name that I didn't
expect: 3/8
Aug 29 23:10:06 qa1gsp2-eth1 kernel: nfsd-fh: found a name that I didn't
expect: 2/7

    Of course, once this happens, nfs clients are unable to list these
directories.
    After investigating, it looks like in nfsfh.c, find_fh_dentry() which
translates the fh to a dentry and if it is a disconnected dentry splices it
into the dentry cache, finds a problem with the dcache. In this case,
nfsd_iget() on the inode specified in the fh returns a new inode and a
disconnected dentry. find_fh_dentry() then looks up the dentry for its
parent and calls splice() to wire the child dentry into the dcache. However
splice() finds that there exists a dentry for the same inode already wired
to the parent dentry, complains and quits. It is as if this pre-existing
inode never got put on the i_hash list. My theory so far is that iget
somehow got called on the offending inode that ended up creating a dentry
for it, but never put the inode on the i_hash list. However, I can't find
the place in the code where this could have happened.
    There is also this mysterious comment in nfsd_iget that says iget()
should never be called on an unallocated inode, even though it has code to
handle precisely this case.  I'm confused by this comment. Plausibly, with
this failover scenario described above, there's a high probability that a
lot of handles presented to the server will result in disconnected dentries
being created and then spliced into the dcache.
    I realize that some nfs operations will be lost in this setup. However,
I'm prepared to tolerate that. I just need the above problem not block
access to directories.

Any help would be extremely useful.

Thanks,
Sumanth



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: Write Cache consistancy and NFS sync
Date: Wed, 20 Mar 2002 16:05:45 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <49CA7FE2A83A33459A2CD27E99E90EFB0BAE48@poexmb1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Received: from usamail2.conoco.com ([12.31.208.227])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16noDO-0007BF-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 14:05:50 -0800
To: <nfs@lists.sourceforge.net>
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

Hello,

We have an application that works in the following=20
way:

We have a remote NFS node that starts a job, the
job rsh's to the NFS server node and "reserves" the
disk space locally, after this has started the job=20
on the remote NFS node keeps a very careful eye
on how big the file being reserved is, and if this
file is large enough to do the write it currently=20
wants to do, it writes the data over nfs to this=20
file, otherwise the job will hang until the reserved
file has reserved enough to meet its currently write.
The reserve is being done so that long running jobs
are able to claim all of the space that they need and
not run out after lots of work has been done.   The
reserve is a fairly simple process that simply=20
writes lots of zeros to the disk to make sure
the disk space has actually been claimed (fairly
similar to the mkfile program on some unix variants).

Now the question is that if remote NFS client is
running sync, and if the local machine's reserve
is running async (but in the local write
cache-I assume that some of the size of the file
that stat sees is still in the write cache as=20
opposed to really on the disk) does NFS deal with
this in such a manner that there is no chance of
the NFS data getting written to the file on disk and=20
then the local NFS server write cache getting later
flushed over that data from the local asyc write from
the local write cache?

We have been using the above for several weeks and
have so far only found one instance of data corruption,
and are unsure exactly what happened to cause the
corruption, whether some sort of race condition
caused the local write cache on the nfs server to
not yet be flushed and cause the nfs client data
to be written under it, or whether something entirely
different is going on to cause the corruption.
The application in question has fairly good crc
data on most of its data structures, and unless
the corruption takes out the entire structure and
the crc the crc won't match and we get a warning=20
error.   But in the corruption case we had, the
data toward the end of the file was all zeros rather
than the data that should be there.  On reruns
this behavior was not duplicated.

			Roger



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

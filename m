From: Joachim Worringen <joachim@ccrl-nece.de>
Subject: multiple processes appending data to a single file
Date: Tue, 22 Mar 2005 17:45:56 +0100
Message-ID: <42404BC4.9070105@ccrl-nece.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDmWX-0003Be-DF
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 08:46:33 -0800
Received: from www.ccrl-nece.de ([195.37.61.70] helo=convict.ccrl-nece.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDmWA-0005X9-Qf
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 08:46:32 -0800
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


Dear NFS experts,

I posted the problem description below to comp.protocols.nfs without a 
real response (only one "it should work" reply - but it doesn't...). So, 
here comes the problem, below are my questions.

Consider the situation of an empty file, and two processes A and B 
concurrently write N bytes to this file via NFS. Process A writes to 
offset 0, and process B lseeks() to offset N to write there. 
Additionally, each process write-locks the range it is accessing before 
actually doing so.

Please note that this is different from the "append-to-file-via-NFS" 
problem that has been discussed to some degree already. Here, each 
process seeks to a known (non-conflicting) position to write its data.

We have observed that for the described access pattern, it can happen 
that after the write operations, the file contains all zeros for offsets 
0..N-1, and the data of process B between N..2N-1. This means, the data 
of process A is lost. Obviously, to comply with POSIX, the write 
operation of process B implied filling up the "gap" between 0 and N-1 
with zeros, overwriting the data of process A (although it locked it's 
range!). This showed up with different NFS server implementations (Linux 
being one of them) and a single NFS client implementation (SUPER-UX) 
which makes us think that this might be a problem of the client. But on 
the other hand, the client is not necessarily involved at all.

Some questions that we have in this context:
- Has anyone experienced this problem?
- Is the expected behaviour defined anywhere? I found nothing related on 
the web, and neither in the NFSv3 RFC.
- Shouldn't the locking prevent the observed behaviour (meaning there's 
a bug somewhere)?
- Which kind of request is generated for such an append situation by the 
NFS client? Does it care at all if there's a gap?
- What does the server do - does it handle this gap in any way, or does 
it rely on the underlying local file system?

  thanks, Joachim

-- 
Joachim Worringen - NEC C&C research lab St.Augustin
fon +49-2241-9252.20 - fax .99 - http://www.ccrl-nece.de


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Troy Wu <troy@sequence.stanford.edu>
Subject: NFS/2.4.18/reiserfs question
Date: Tue, 10 Sep 2002 16:29:31 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44L1.0209101624160.6472-100000@sequence.stanford.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS at SourceForge <NFS@lists.sourceforge.net>
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

I've got a Dell PE-1550 with a PERC3-DC (dual channel) RAID card.  I'm
using ReiserFS 3.6.25 but with a 3.5.x file format on-disk.  I'm having
trouble symlinking in a directory which contains hundreds of thousands of
files to another directory slightly smaller.

	After I make the link, I get garbage in a 'ls -lF'; i.e., the
	listing shows the correct target, but adds what looks like
	line-noise to the end of the filename.  Of course, the link is
	broken, and eventually, the kernel loses its mind and crashes the
	machine.

I've been doing some reading on ReiserFS and know that it has trouble with
NFS in certain situations.  I'd like to know if my problem is NFS-related
or ReiserFS-related.  Can someone help me understand what that situation
is, how to determine if I'm in that situation, and possibly help me to
decide (if ReiserFS is the problem) if XFS will help?

Thanks,

	--troy



-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Tom McNeal <trmcneal@attbi.com>
Subject: NFS Utils package
Date: Mon, 15 Apr 2002 13:04:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CBB3234.A357666@attbi.com>
References: <20020407072945.GN30807@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16xCgN-0007o7-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Apr 2002 13:02:35 -0700
Received: from attbi.com ([12.234.31.73]) by rwcrmhc52.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with ESMTP
          id <20020415200227.NSWD1901.rwcrmhc52.attbi.com@attbi.com>
          for <nfs@lists.sourceforge.net>; Mon, 15 Apr 2002 20:02:27 +0000
To: nfs@lists.sourceforge.net
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

Hi -

I've exported an NFS Utils package based on the latest checkins
on the CVS tree, which H.J. tagged as nfs-utils-1-0-1-pre3.  I
have tested it with 2.2, 2.4, and Solaris 7 servers, running with
a 2.4.18 client, running all 4 Connectathon 2002 tests simultaneously,
along with bonnie++ and a duplicate request cache test I developed
last year.  I set them up to run 20 times each, so there is a
constant mix of various tests doing different things for a few
hours in each test sequence. 

You can download the package from sourceforge:

http://nfs.sourceforge.net/nfs-utils-1-0-1-pre3.tar.gz

The notes for all the modifications are in the ChangeLog file
in the package.  The one that is of most importance to me is
the modification of the default behavior for nfs exports; The
default is now "sync", and you will get a warning if you don't
specify either "sync" or "async".

I will be out of town for a week or so, and won't be able to 
read the mailing list much at all, but I'll be reviewing status
later on next week, so go ahead and post comments to the mailing
list, and send any private mail directly to me at this address.

Regards -

Tom McNeal

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

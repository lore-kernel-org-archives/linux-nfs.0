From: trmcneal@attbi.com
Subject: Re: NFS Utils package
Date: Wed, 17 Apr 2002 15:26:06 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020417152606.ZJBT15826.rwcrmhc54.attbi.com@rwcrwbc56>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc54.attbi.com ([216.148.227.87])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16xrK0-0001UI-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Apr 2002 08:26:12 -0700
To: ed@sam-solutions.net (Ed V. Bartosh)
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

The connectathon tests can be downloaded from
http://www.connectathon.org/nfstests.html
and the bonnie++ load I added came from
http://www.coker.com.au/bonnie++

I'm intending to rerun cthon02 with iozone as the
background load, when I am home again next week.  That
can be found at http://www.iozone.org, and I put some
instructions for running it in the performance section
of the NFS howto.

I won't have access to my duplicate request cache test
until next week, but connectathon does cover that.  One
thing to look for with 2.2 systems that don't support
large file sizes (> 2 gb) is that the special tests will
fail, but you can comment out the last test of the
special test sequence ("bigfile") to avoid that, if you
want.

Tom
> 
> Hi, Tom!
> 
> /Mon, 15 Apr 2002 13:04:04 -0700/ you wrote:
> 
> TM> I've exported an NFS Utils package based on the latest checkins
> TM> on the CVS tree, which H.J. tagged as nfs-utils-1-0-1-pre3.  I
> TM> have tested it with 2.2, 2.4, and Solaris 7 servers, running with
> TM> a 2.4.18 client, running all 4 Connectathon 2002 tests simultaneously,
> TM> along with bonnie++ and a duplicate request cache test I developed
> TM> last year.  
> Are your tests able for download somewhere ?
> Do you know another nfs tests ?
> 
> TM> You can download the package from sourceforge:
> 
> TM> http://nfs.sourceforge.net/nfs-utils-1-0-1-pre3.tar.gz
> Thank you, Tom.
> 
> And what about nfs-utils 1.0 ? It was mentioned here a couple of
> month ago, but can't find it on sourceforge nfs page.
> 
> -- 
> Best regards,
> Ed V. Bartosh
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

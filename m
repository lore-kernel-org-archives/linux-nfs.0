From: Poul Petersen <petersp@roguewave.com>
Subject: RE: Performance Woes...
Date: Wed, 5 Jun 2002 13:06:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F888C30C3021D411B9DA00B0D0209BE8038F9523@cvo-exchange.cvo.roguewave.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cvo-ext.roguewave.com ([12.22.36.198] helo=cvo-exchange.cvo.roguewave.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Fh6U-0006tS-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Jun 2002 13:09:58 -0700
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

>   while : ; do netstat -n -u -a | grep :2049 ; sleep 1; done
> 
> I get:
> udp      348      0 0.0.0.0:2049            0.0.0.0:*         
>                   
>                   
> udp     2436      0 0.0.0.0:2049            0.0.0.0:*         
>                   
>        ^^^^^^
> 
> Note this column of numbers.  If it hits a ceiling at 65536, you have
> a problem that can be fixed.  See the NFS FAQ, or show me the numbers
> and I will explain.

	Interesting - In the half hour or so that I've watched our NFS
server, this number has hit 65406. It isn't clear to me what section of the
NFS FAQ (http://nfs.sourceforge.net/) is relevant to this test. 

	The other thing in this post that caught my eye was mention of the
2.4.18 NFSALL patch. I presume this is the patch located at
http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.18/patch-Bd-NfsdA
ll.gz How does this, or does it, relate to the post from Hirokazu Takahashi:
http://www.geocrawler.com/archives/3/789/2002/4/0/8479569/ which seems to
also be related to BKL removal. Of particular interest to me in Hirokazu's
post is mention of some kernel Oops fixes that I think we might be seeing.
We are running a RedHat 7.2 box with kernel 2.4.18, XFS 1.1, nfs-utils-0.3.3
and we have had all sorts of strange Oops's and hangs. Are there other
patches we should consider applying to a 2.4.18 NFS server? Does the NFSALL
patch address any stability issues or is it mostly to add V3TCP?
Unfortunately, we are stuck at 2.4.18 until we can get rid of XFS (I think
XFS is the source of most of our problems, but we are starting to look at
NFS as well)

Thanks for any insight...

-poul

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "tina arora" <tinaarora@hotmail.com>
Subject: NFS not working??
Date: Wed, 24 Apr 2002 08:34:46 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F63aiTGMQGWw8khyhC0000169ed@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f63.law15.hotmail.com ([64.4.23.63] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170IEr-0007eU-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 01:34:57 -0700
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

Hello friends thanx so much 4 replying to my yesterday's  query.
heres 1 more..
I downloaded nfs-utils-0.3.3 and executed all the four commands
#./configure
# make
#make install
#rpm -ta nfs-utils-0.3.3.tar.gz
everything went fine but when i tried to verify NFS with rpcinfo -p =
command I got only 4 lines in the output (2 for portmap and 2 for =
status)
and none for rquotad or mountd or nfs or amd or nlockmgr..
Readme of this nfs utility says that to build the source & binary RPMs, =
mount in util-linux 2.11f or above is required ..
I have a mount version of 2.11b ...
Can the above problem be caused coz of mount version problem..
please help me out..
other nfs-utilities say u shud not have a too old mount version ...what =
is meant by too old mount version.. please try to be specific..
thanx n bye
Tina



_________________________________________________________________
MSN Photos is the easiest way to share and print your photos: 
http://photos.msn.com/support/worldwide.aspx


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

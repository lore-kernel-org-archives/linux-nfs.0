From: Bruce Robertson <bruce@greatbasin.net>
Subject: Re: Maximum number of nfsd daemons?
Date: Fri, 02 Aug 2002 10:05:39 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208021705.g72H5e204213@roo.greatbasin.net>
References: <15689.54017.692185.573037@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail1.greatbasin.net ([207.228.35.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17afs1-0007Lz-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 10:05:45 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: Your message of "Fri, 02 Aug 2002 10:32:01 +1000."
             <15689.54017.692185.573037@notabene.cse.unsw.edu.au>
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

Would you bother with more threads in this situation?  The server's been
up 133 days; doesn't seem like it's worth messing with it if the last
thread has only been used for 11 seconds.  I might increase it for the next
reboot (if ever :-), but I don't really want to bother with restarting nfsd:

rc 253405 247133819 2102736339
fh 164627 2388074384 0 0 0
io 1879707623 1245239505
th 20 802 499059.350 179740.290 95589.220 38896.840 13428.490 4192.740 1125.820 239.110 45.190 11.020
ra 40 205615873 1051844 560093 330858 220535 154846 109266 81350 66170 63103 0
net -1944843733 -1944843733 0 0
rpc -1944843733 0 0 0 0
proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 0 42738275 24032239 215924238 1550591333 20714 233998756 172948575 24818081 13323 20691 0 24789604 13179 733268 18264 74781 0 171980 110430 0 59105832



--
Bruce Robertson, President/CEO				     +1-775-348-7299
Great Basin Internet Services, Inc.			fax: +1-775-348-9412
http://www.greatbasin.net




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

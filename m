From: Matthew Boeckman <matthewb@saepio.com>
Subject: nfsstat limitations?
Date: Mon, 25 Mar 2002 10:09:49 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C9F4BCD.5050404@saepio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from [208.10.117.3] (helo=velocity.saepio.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pX3V-00083p-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 08:10:45 -0800
Received: from saepio.com (leto-ii [10.1.1.100])
	by velocity.saepio.com (8.11.2/8.9.3) with ESMTP id g2PHFE122178
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 11:15:14 -0600
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

Hello list!

I'm trying to track down some information about the nfsstat on linux. 
Specifically from nfs-utils-0.3.1-5 on RH7.1 . What I'm looking for is 
some additional client RPC information. nfsstat on solaris gives me all 
kinds of nifty output about timeouts, badcalls, timers, etc:
Client rpc:
Connection oriented:
calls       badcalls    badxids     timeouts    newcreds    badverfs
0           0           0           0           0           0
timers      cantconn    nomem       interrupts
0           0           0           0
Connectionless:
calls       badcalls    retrans     badxids     timeouts    newcreds
4           1           0           0           0           0
badverfs    timers      nomem       cantsend
0           1           0           0

on linux:
Client rpc stats:
calls      retrans    authrefrsh
70163      12         0

I've read the man page and docs on the sourceforge site, and it doesn't 
appear that I'm missing any command line options. Is there somewhere 
other than nfsstat that I can get this info?

Another question along the same lines: how can I track client side NFS 
cache hit's and caching information in general? For a variety of 
reasons, I'm caching the entire mounted filesystem for a long time, and 
am interested/concerned in being able to track the system impact of 
that. Things like, of all NFS calls, how many are being answered by the 
cache, how much system resources is this cache taking up, etc. Thanks 
for any and all replies!

-Matthew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

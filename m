From: Campbell McLeay <campbellm@cia.net.au>
Subject: Problems with Stale File Handles as non-root user
Date: Mon, 24 Jun 2002 00:18:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020624001859.A14403@cia.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.cia.net.au ([203.17.36.17] helo=cia.com.au)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17M8Cl-0004x4-00
	for <nfs@lists.sourceforge.net>; Sun, 23 Jun 2002 07:19:03 -0700
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

Hi,

I have a directory that is mounted via NFS over a 100 Base-T LAN
and it gets 'Stale NFS File handle' errors after short periods of
inactivity (say, a few minutes) For instance, commands such as 'ls' in the 
nfs-mounted directory return the stale file handle error after a couple of minutes
idle time. Any operation attempting to read/write to the directory fails with the
same error when the user is non-root.

Interestingly, this only happens with non-root users: when logged
in as root, no errors occur.

The nfs server is running Debian/GNU potato Linux with 2.4.18 kernel
with v3 support compiled in (although I can only get it to
do v2) and the client is running the same but with a 2.2.19 kernel. I have
tried remounting it as v3 but the server does not appear to 
be able to do this (I can't use '-N 1 -N 2' with mountd as suggested in the FAQ).

AFAIK, there is no known network issue with the LAN (it works fine as root always in any case).
The versions of nfs-server and nfs-common on each machine are the latest debian
versions (i.e., 2.2beta47-4potato for the server and 0.1.9.1-1.potato for 
nfs-common. The version of mount is 2.10f-5.1). 


Any ideas on how to solve this problem would be greatly appreciated.

Regards,

Campbell


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

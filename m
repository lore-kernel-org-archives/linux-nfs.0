From: Ulrich Hochholdinger <hochhold@fzi.de>
Subject: Timeout-problems
Date: Sat, 16 Mar 2002 19:47:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020316184735.GA13908@lotus.fzi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from gate.fzi.de ([141.21.4.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mJDz-0001zI-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Mar 2002 10:48:16 -0800
Received: from hochhold by lotus.fzi.de with local (Exim 3.34 #1 (Debian))
          id 16mJDV-0003dQ-00 for <nfs@lists.sourceforge.net>;
          Sat, 16 Mar 2002 19:47:45 +0100
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
I've some strange problems here with my nfs-server.

Mounting filesystems works only sometimes and then with long timeouts.

For example:
On the Client:
$> mount -tnfs server:/Mirror /Mirror
the system waits some time and then I get a
mount: RPC: Timed out
Then I wait some 5 minutes doing nothing, and try it again, now sometimes
the mount process will work successfull and I can access all files on the
mounted drive.
I tried this with nfsv2 and nfsv3  and with and without tcp.

The next thing is when a mount failed, I try on the server a 
showmount -e localhost or showmount -a localhost
and I get a:
rpc mount export: RPC: Timed out
the same from the client
waiting some 2 minutes this wil work again...
an rpcinfo -p server (from client and server side) shows the same ports
on the client side I also made all rpc-services available for the server
(hosts_access)
Additionally I've no IP-filters/chains running on these machines.

my /etc/exports shows this line:
-----
/Mirror @some-netgroup(rw,no_root_squash) client1(rw,no_root_squash) client2(rw,no_root_squash)
------ (chaneged the original host-names :)

An tcpdump on both sides shows that no packages are lost,
simply the mountd isn't responding...


The Server is a Dual PIII Box with linux-2.4.18 nfs compiled with nfsv3
support for server and client both as modules. The operating system is
Debian woody. Network card is a 3com 3c905b.
The client is a Dell PIII Laptop with built in ethernet card (3Com 3c556
Laptop Tornado), running linux-2.4.17 also nfs compiled with nfsv3 and 
as module and running Debian woody.
They communicate over an 3Com SuperStack II switch 3000


Gruss
	Ulli

-- 
\ Ulli Hochholdinger                        E-Mail: ulli@hochholdinger.net \
/ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ /
\ Sometimes I think the surest sign that intelligent life exists elsewhere \
/ in the universe is that none of it has tried to contact us. (Calvin)     /

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

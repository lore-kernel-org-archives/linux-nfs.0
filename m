From: Jan Sedlacek <jan.sedlacek@asicentrum.cz>
Subject: NFS server RH7.1, kernel 2.4.18, client Solaris 7
Date: Mon, 25 Mar 2002 14:28:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C9F25FF.1000203@asicentrum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Received: from gate.asicentrum.cz ([195.39.24.82] helo=mravenec)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pUWc-0004cE-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 05:28:39 -0800
Received: from localhost ([127.0.0.1])
	by mravenec (Kerio MailServer 5.0.5)
	for nfs@lists.sourceforge.net;
	Mon, 25 Mar 2002 14:28:31 +0100
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

Hi all,

    I have the following problem,

I've upgraded to RedHat Linux 7.1 with kernel 2.4.18 (compiled with 
options NFSv3 server and client support checked). Clients are RH Linux 
6.1, 6.2, 7.0, 7.1 and Solaris 7.
Linux clients work fine without any problem. Solaris 7 clients work fine 
only without locking files. If I try on Solaris to start old openwindows 
file manager (filemgr) it hangs for five minutes and reports just 
"nfs-server: RPC timed out". I think the problem is locking files. I 
tried on NFS server to set "insecure_locks" and "no_auth_nlm" options in 
/etc/exports file, but it didn`t help.

NFS server rpcinfo shows:

   program verz proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100007    2   udp    781  ypbind
    100007    1   udp    781  ypbind
    100007    2   tcp    784  ypbind
    100007    1   tcp    784  ypbind
    100011    1   udp    735  rquotad
    100011    2   udp    735  rquotad
    100005    1   udp  32889  mountd
    100005    1   tcp  32845  mountd
    100005    2   udp  32889  mountd
    100005    2   tcp  32845  mountd
    100005    3   udp  32889  mountd
    100005    3   tcp  32845  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32890  nlockmgr
    100021    3   udp  32890  nlockmgr
    100021    4   udp  32890  nlockmgr                  

,so lock manager is running (as rpc.statd is running).

Any idea is very appreciated.

Regards,

Sedlon




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: chandrashekhar dethe <cgdethe@yahoo.com>
Subject: help
Date: Fri, 30 May 2003 19:25:45 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030531022545.131.qmail@web10801.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1259007764-1054347945=:99837"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web10801.mail.yahoo.com ([216.136.130.243])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Lw41-0001TQ-00
	for <nfs@lists.sourceforge.net>; Fri, 30 May 2003 19:25:45 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

--0-1259007764-1054347945=:99837
Content-Type: text/plain; charset=us-ascii
Content-Id: 
Content-Disposition: inline

Dear All,
I have been trying to mount server fs on the client
using nfs, but could not be successful in mounting fs.
Herewith I am attaching three files which can be
helpful to suggest the remedy.
1) test.txt  file - is a error message
2) rpcinfo_localhost.txt
3) rpcinfo_server.txt
Pl. suggest the appropriate remedy.

 

=====
with regards,

- C.G.DETHE.

__________________________________
Do you Yahoo!?
Yahoo! Calendar - Free online calendar with sync to Outlook(TM).
http://calendar.yahoo.com
--0-1259007764-1054347945=:99837
Content-Type: text/plain; name="rpcinfo_localhost.txt"
Content-Description: rpcinfo_localhost.txt
Content-Disposition: inline; filename="rpcinfo_localhost.txt"

[root@durga cgdethe]# /usr/sbin/rpcinfo -p 192.168.254.76
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    391002    2   tcp   1025  sgi_fam
    100011    1   udp   1008  rquotad
    100011    2   udp   1008  rquotad
    100011    1   tcp   1011  rquotad
    100011    2   tcp   1011  rquotad
    100005    1   udp   1025  mountd
    100005    1   tcp   1026  mountd
    100005    2   udp   1025  mountd
    100005    2   tcp   1026  mountd
    100005    3   udp   1025  mountd
    100005    3   tcp   1026  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1026  nlockmgr
    100021    3   udp   1026  nlockmgr
    100021    4   udp   1026  nlockmgr
    300019    1   tcp    622  amd
    300019    1   udp    623  amd


--0-1259007764-1054347945=:99837
Content-Type: text/plain; name="rpcinfo_server.txt"
Content-Description: rpcinfo_server.txt
Content-Disposition: inline; filename="rpcinfo_server.txt"

[root@etc hpc_course]# /usr/sbin/rpcinfo -p 192.168.254.75
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    391002    2   tcp   1025  sgi_fam
    100011    1   udp   1015  rquotad
    100011    2   udp   1015  rquotad
    100011    1   tcp   1018  rquotad
    100011    2   tcp   1018  rquotad
    100005    1   udp   1026  mountd
    100005    1   tcp   1026  mountd
    100005    2   udp   1026  mountd
    100005    2   tcp   1026  mountd
    100005    3   udp   1026  mountd
    100005    3   tcp   1026  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1027  nlockmgr
    100021    3   udp   1027  nlockmgr
    100021    4   udp   1027  nlockmgr

--0-1259007764-1054347945=:99837
Content-Type: text/plain; name="test.txt"
Content-Description: test.txt
Content-Disposition: inline; filename="test.txt"

[root@durga cgdethe]#  mount 192.168.254.75:/home /shrikant
mount: RPC: Port mapper failure - RPC: Unable to receive
[root@durga cgdethe]# mount 192.168.254.75:/home /home/cgdethe
mount: RPC: Port mapper failure - RPC: Unable to receive


--0-1259007764-1054347945=:99837--


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

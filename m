From: Suresh Chadive <n8d11007@ccs.iitb.ac.in>
Subject: NFS problem
Date: Wed, 21 Aug 2002 05:31:08 +0530 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GHP.4.43.0208210529460.22003-100000@hp10.ccs.iitb.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhost.iitb.ac.in ([203.197.74.142])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hIsi-0001A3-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 16:57:52 -0700
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



There has been a problem in mounting the directory
on the client.

PROBLEM :-
----------
If the command :
  $ mount serverIPaddress:/home /home
is issued, then the output is
  mount: RPC: Timed out


INFO THAT MAY BE USEFUL :-
-------------------------

SERVER SIDE :

  $ rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp   1025  sgi_fam
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1027  nlockmgr
    100021    3   udp   1027  nlockmgr
    100021    4   udp   1027  nlockmgr
    100011    1   udp    755  rquotad
    100011    2   udp    755  rquotad
    100011    1   tcp    758  rquotad
    100011    2   tcp    758  rquotad
    100005    1   udp   1028  mountd
    100005    1   tcp   1030  mountd
    100005    2   udp   1028  mountd
    100005    2   tcp   1030  mountd
    100005    3   udp   1028  mountd
    100005    3   tcp   1030  mountd
    100024    1   udp   1029  status
    100024    1   tcp   1031  status



CLIENT SIDE:

    $  rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam

Here, I explicitly run rpc.lockd (on client)
but still, I do not see lock daemon (nslockmanager or some thing of that
sort) ! Any clue?
---------------------------------------------------

Please, give some way to sort it out...

-suresh


----------------------
SURESH CHADIVE

V Yr,
Dual degree Programme

H9, #319,
Indian Instt. of Technology,
Bombay

e-mail :  csuresh@iitbombay.org







-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

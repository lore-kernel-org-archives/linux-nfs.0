From: Patrick O'Reilly <patrick.oreilly@uni.edu>
Subject: Re: NFS problem
Date: Wed, 21 Aug 2002 10:30:19 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <005c01c24927$a8704f40$66f1a186@OREILLY>
References: <Pine.GHP.4.43.0208210529460.22003-100000@hp10.ccs.iitb.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cougar.uni.edu ([134.161.1.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hXQj-0003N7-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 08:29:57 -0700
Received: from OREILLY ([134.161.241.102]) by uni.edu (PMDF V6.1-1 #30560)
 with SMTP id <01KLK1IIBRIY8WWE5Z@uni.edu> for nfs@lists.sourceforge.net; Wed,
 21 Aug 2002 10:29:48 -0500 (CDT)
To: Suresh Chadive <n8d11007@ccs.iitb.ac.in>, nfs@lists.sourceforge.net
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

First, a good page to check is:

http://ftp.belnet.be/packages/redhat/redhat-7.1-en/doc/HOWTOS/other-formats/
html/NFS-HOWTO/server.html#SERVICESTART

to get your services started.  If you are using Linux, you can also try
this. Issue the command:

chkconfig --list

and a list of services will scroll by.  Check to see that portmap, nfs and
nfslock are 'on' on levels 3, 4, and 5.  If not, issue the commands:

chkconfig --level 345 portmap on
chkconfig --level 345 nfs on
chkconfig --level 345 nfslock on

and these should be turned on, and will start on reboot.  Try this on the
client and see what happens if it looks like it will help.  Good luck.

Patrick

----- Original Message -----
From: "Suresh Chadive" <n8d11007@ccs.iitb.ac.in>
To: <nfs@lists.sourceforge.net>
Sent: Tuesday, August 20, 2002 7:01 PM
Subject: [NFS] NFS problem


>
>
> There has been a problem in mounting the directory
> on the client.
>
> PROBLEM :-
> ----------
> If the command :
>   $ mount serverIPaddress:/home /home
> is issued, then the output is
>   mount: RPC: Timed out
>
>
> INFO THAT MAY BE USEFUL :-
> -------------------------
>
> SERVER SIDE :
>
>   $ rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     391002    2   tcp   1025  sgi_fam
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100021    1   udp   1027  nlockmgr
>     100021    3   udp   1027  nlockmgr
>     100021    4   udp   1027  nlockmgr
>     100011    1   udp    755  rquotad
>     100011    2   udp    755  rquotad
>     100011    1   tcp    758  rquotad
>     100011    2   tcp    758  rquotad
>     100005    1   udp   1028  mountd
>     100005    1   tcp   1030  mountd
>     100005    2   udp   1028  mountd
>     100005    2   tcp   1030  mountd
>     100005    3   udp   1028  mountd
>     100005    3   tcp   1030  mountd
>     100024    1   udp   1029  status
>     100024    1   tcp   1031  status
>
>
>
> CLIENT SIDE:
>
>     $  rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  32768  status
>     100024    1   tcp  32768  status
>     391002    2   tcp  32769  sgi_fam
>
> Here, I explicitly run rpc.lockd (on client)
> but still, I do not see lock daemon (nslockmanager or some thing of that
> sort) ! Any clue?
> ---------------------------------------------------
>
> Please, give some way to sort it out...
>
> -suresh
>
>
> ----------------------
> SURESH CHADIVE
>
> V Yr,
> Dual degree Programme
>
> H9, #319,
> Indian Instt. of Technology,
> Bombay
>
> e-mail :  csuresh@iitbombay.org
>
>
>
>
>
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

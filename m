From: "Joseph L. Hood" <nfsmail@acerbus.com>
Subject: Re: NFS problem
Date: Tue, 20 Aug 2002 22:54:06 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208202241440.3445-100000@linux2>
References: <Pine.GHP.4.43.0208210529460.22003-100000@hp10.ccs.iitb.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from staffordstudio.com ([66.92.164.68] helo=linux2.staffordstudio.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hLcs-0007GV-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 19:53:43 -0700
Received: from localhost (jhood@localhost)
	by linux2.staffordstudio.com (8.11.6/8.11.6) with ESMTP id g7L2s6c03519
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 22:54:06 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.GHP.4.43.0208210529460.22003-100000@hp10.ccs.iitb.ernet.in>
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

Problems I've run into getting NFS going are IPChains firewall rules
(IPTables logging is a little less cryptic) and not having portmap running
on the client.  Also, try "rpcinfo -p <server>"  from the client, or
"rpcinfo -u <server> nfs" to see what the client can see.

Additionally, see if you can nfs mount the shared directories from the
server itself, to make sure they are really shared.

Joe

On Wed, 21 Aug 2002, Suresh Chadive wrote:

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
> 




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

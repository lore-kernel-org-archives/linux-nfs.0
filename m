From: Bill Schrier <wschrier@neolinear.com>
Subject: Re: NFS Locking Issue - Solaris-Linux
Date: Tue, 22 Oct 2002 11:21:23 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DB56CF3.29848F2F@neolinear.com>
References: <CFEAJJEGMGECBCJFLGDBMECLCGAA.enorwood@effrem.com>
Reply-To: it@neolinear.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, it@neolinear.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from n5.neolinear.com ([208.20.218.5] helo=flood.neolinear.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1840sA-0004GL-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 08:23:10 -0700
To: Eff Norwood <enorwood@effrem.com>
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

> -Are you using automounter

Yes

> -Are you using NIS (if yes what kind of machine is the master)

No, we are using NIS+ though.  The master and replica servers are both Sparc
Solaris - the master is Solaris 2.6, the replica is Solaris 8.

> -What are your mount options

The corresponding line from our auto_direct table follows:
/zone           -actimeo=0,vers=2       raidzone:/home

The /etc/exports file on the raidzone box looks as follows:
/home   192.9.200.0/255.255.255.0(rw,no_root_squash,insecure,no_auth_nlm)
10.5.0.0/255.255.255.0(rw,insecure,no_
auth_nlm) 10.3.0.0/255.255.255.0(rw,insecure,no_auth_nlm)


> -What's the version of RedHat that works

I don't think I follow you here... Do you mean which Redhat version on the
Raidzone box?  If so, I believe that Raidzone would have been testing with
their most recent kernel version - which is what we are also running.  If you
mean as a client, I believe any version of RedHat is able to successfully lock
files.

> -Solaris Sparc or Solaris Intel

This is all on Solaris Sparc.

> Finally, will the Redhat box as a client lock the Raidzone or is it just the
> Solaris machines?

Yes - files shared from the Raidzone box are able to be locked from
HPUX machines, and other Linux boxes (both Redhat and Debian) on the network.
It is just the Solaris machines that are unable to lock files.

Thanks for the help!  If I can provide any further information, please don't
hesitate to ask.

Bill

--
William J. Schrier              Phone: 412.968.5780 x151
Neolinear, Inc.                 Fax:   412.968.5788
583 Epsilon Drive               Email: wschrier@neolinear.com
Pittsburgh, PA  15238





-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: NFS Locking Issue - Solaris-Linux
Date: Tue, 22 Oct 2002 07:52:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBMECLCGAA.enorwood@effrem.com>
References: <3DB55BCC.447F0C32@neolinear.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <it@neolinear.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1840Ol-0002GQ-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 07:52:47 -0700
To: "Bill Schrier" <wschrier@neolinear.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <3DB55BCC.447F0C32@neolinear.com>
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

Hi Bill,

There are a bunch of other variables I'd like to know about.

-Are you using automounter
-Are you using NIS (if yes what kind of machine is the master)
-What are your mount options
-What's the version of RedHat that works
-Solaris Sparc or Solaris Intel

Finally, will the Redhat box as a client lock the Raidzone or is it just the
Solaris machines?

Eff Norwood




-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

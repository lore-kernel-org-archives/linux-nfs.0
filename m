From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question about performance...
Date: 31 Jan 2003 17:42:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslm11feyh.fsf@charged.uio.no>
References: <010d01c2c942$9c7c94f0$6601a8c0@userl3x55qxqed>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18eeFi-0004HP-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 08:42:54 -0800
To: "Matt Heaton" <admin@0catch.com>
In-Reply-To: <010d01c2c942$9c7c94f0$6601a8c0@userl3x55qxqed>
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

>>>>> " " =3D=3D Matt Heaton <admin@0catch.com> writes:

     > Hello all... I have 3 HUGE NFS servers (Each one with 2 -3
     > terabytes each), and 10 clients that pull a consistent 20-25
     > MBit total off of

     > the 3 NFS servers.=A0 Everything is running fine, but performance
     > isn't the greatest... I can never pull more than 1 Megabyte per
     > second off of any of the servers (Even though local performance
     > of drives on the servers is GREAT)...=A0 My question is this?=A0
     > How would switching everything to gigabit copper instead of 100
     > MBit lines help.=A0=A0 Obviously Gig is faster, but since I am not
     > even using the 100 MBit I am wondering?=A0 The latency should go
     > down because it transfers so much faster?=A0 Any ideas for me?=A0
     > Anyone do this themselves that can answer?

You should be getting 10Mbyte/sec on a switched 100Mbit line. I
suggest you try NFS over TCP rather than UDP (note that this requires
a fairly recent kernel -2.4.20 or above- on the server side).

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

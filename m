From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: 04 Sep 2003 16:38:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsekywl26q.fsf@charged.uio.no>
References: <shsekzcjnbt.fsf@charged.uio.no>
	<Pine.LNX.4.44.0309041128520.5868-100000@fubar.phlinux.com>
	<16215.39899.241145.441186@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19v0s0-0004Gl-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 13:38:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19v0rx-0000X9-U2
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 13:38:18 -0700
To: Matt C <wago@phlinux.com>
In-Reply-To: <16215.39899.241145.441186@charged.uio.no>
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

>>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

     > The rpc_update_rtt() function is pretty standard. It is
     > documented in a paper by Van Jacobson from 1998. See:
     >     http://www-nrg.ee.lbl.gov/nrg-papers.html

Errr... The above date should of course be 1988. Paper is called
"Congestion Avoidance and Control".

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

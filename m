From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: Must statd be running before nfs client makes mounts?
Date: Mon, 16 Sep 2002 20:08:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020916200808.A13247@lucon.org>
References: <20020915225226.GI11002@perlsupport.com> <15749.5917.443602.600792@notabene.cse.unsw.edu.au> <20020915164956.A21841@lucon.org> <15749.7947.298657.940521@notabene.cse.unsw.edu.au> <20020916071259.B1149@lucon.org> <15750.26762.274141.71457@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17r8kQ-0005KH-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 20:09:58 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15750.26762.274141.71457@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Tue, Sep 17, 2002 at 09:26:02AM +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Tue, Sep 17, 2002 at 09:26:02AM +1000, Neil Brown wrote:
> 
> Certainly it would be nice to have a single mechanism that always
> worked, but I don't think the kernel infrastructure is up to that at

Well, nfssvc(port, count) works for all. Why can't lockdport (tcp, udp)?


H.J.


-------------------------------------------------------
Sponsored by: AMD - Your access to the experts on Hammer Technology! 
Open Source & Linux Developers, register now for the AMD Developer 
Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: current Trond NFS patch for 2.2.22?
Date: 08 Oct 2002 03:56:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65wd7kxh.fsf@charged.uio.no>
References: <20021007183704.K24367@questra.com>
	<shsfzvhsszs.fsf@charged.uio.no> <20021007213843.M26432@questra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yjbx-0001Jg-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 18:56:37 -0700
To: Scott McDermott <mcdermot@questra.com>
In-Reply-To: <20021007213843.M26432@questra.com>
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

>>>>> " " == Scott McDermott <mcdermot@questra.com> writes:

     > Trond Myklebust on Tue 8/10 01:56 +0200:
    >> >>>>> " " == Scott McDermott <mcdermot@questra.com> writes:

     > what's this empty string? where does it get its value? my MUA
     > set up improperly or something?

Nah. Xemacs wants to play games when formatting. I just hate having
the thing indent with

   Scott McDermott> blah...

     > biggest thing stopping me from upgrading the servers to 2.4 is
     > knowing that everyone will get stale handles, this will be very
     > hard to manage logistically, too many disparate political units
     > with clients mounting off it.  You said before that there is
     > server code to handle old 2.2 cookies but I've heard otherwise
     > from posts on the list and 2.2 works too well for us right now
     > to risk this.  I really should get around to testing this
     > though.  Truth is, 2.2 works well for our needs, I don't really
     > care to upgrade until we get something worthwhile like RPCSEC
     > and ACL support.

Nobody is forcing you to upgrade, however I wanted to make the point
that 2.2.x is a 'critical fixes only' kernel. Otherwise I'm not
touching it...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

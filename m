From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Tue, 29 Oct 2002 17:49:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15806.48160.519752.117620@charged.uio.no>
References: <15805.26221.530836.279218@charged.uio.no>
	<20021029.153629.55720711.taka@valinux.co.jp>
	<15806.42148.47823.817360@charged.uio.no>
	<20021030.012731.104039610.taka@valinux.co.jp>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186ZYs-0000vz-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 08:49:50 -0800
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021030.012731.104039610.taka@valinux.co.jp>
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

>>>>> " " == Hirokazu Takahashi <taka@valinux.co.jp> writes:

    >> Unless, of course, you've got another use for the
    >> head_page/tail_page?

     > I just wanted to make it general.  I guessed head_page (or
     > head_pages) might be usefull for big NFSv4 COMPOUND messages as
     > we could send a head without any copies.  But it's just my
     > guess.

It's good to know that this is possible, but lets not overdesign: we
don't want to implement this unless we know that we have a need.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

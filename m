From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3 not supported ?
Date: 01 Sep 2002 21:30:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadn1tsn5.fsf@charged.uio.no>
References: <3D7255DD.BFBBA4E5@arx.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17laQT-00023d-00
	for <nfs@lists.sourceforge.net>; Sun, 01 Sep 2002 12:30:25 -0700
To: Thanos Chatziathanassiou <tchatzi@arx.gr>
In-Reply-To: <3D7255DD.BFBBA4E5@arx.gr>
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

>>>>> " " == Thanos Chatziathanassiou <tchatzi@arx.gr> writes:

     > Can anyone explain this ? Is NFSv3 meant to be only compiled as
     > a module ?

No. Looks like you've screwed up somewhere when you did the
compilation. Did you for edit .config by hand? If so, did you remember
to do 'make oldconfig' before compiling?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

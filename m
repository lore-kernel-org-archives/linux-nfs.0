From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: General network slowness on SIS 530 with eepro100
Date: 14 Aug 2002 03:13:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8359.24570351399$1029287806@news.gmane.org>
References: <20020813212923.L2219@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eepro100@scyld.com, nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17emjj-00009l-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 18:14:11 -0700
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20020813212923.L2219@blackjesus.async.com.br>
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

>>>>> " " == Christian Reis <kiko@async.com.br> writes:

     > Helle there,

     > I've been, for the past days, setting up a fairly big diskless
     > network based on Linux. I've chosen to use 2.4.19 as the kernel
     > because there were some hardware requirements, and for most of
     > the newer boxes, it runs fine. However, for three of the older
     > boxes, we have had some pretty odd performance and stability
     > issues. This message is about the latest one, which is an ASUS
     > P5S-B (has the infamous SIS 530 chipset) on an intel eepro100
     > card. Details:

Is all this NFS over UDP? If so, numbers should not really have
changed in 2.4.19 ( - yes my patchset changes things, but stock 2.4.19
should not be too different w.r.t 2.4.18)

Are you able to determine where in the 2.4.19-pre series the
performance dies?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

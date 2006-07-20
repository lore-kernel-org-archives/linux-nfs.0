From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: nfs problems with 2.6.18-rc1
Date: Thu, 20 Jul 2006 10:11:43 +0200
Message-ID: <20060720081143.GA1408@janus>
References: <priv$8d118c145575$b19af6759a@200607.shadow.banki.hu>
	<17594.51834.20365.820166@cse.unsw.edu.au>
	<priv$efbe06145615$0a94d550eb@200607.gmail.com>
	<priv$8d118c145627$464a3143cd@200607.shadow.banki.hu>
	<17597.28376.805867.197599@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Janos Farkas <chexum+dev@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3TdQ-0007CN-Ma
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 01:11:52 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G3TdP-0005A1-PE
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 01:11:53 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17597.28376.805867.197599@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Jul 19, 2006 at 09:29:28AM +1000, Neil Brown wrote:
[...]
> 
> > 13:37:51.254708 access fh Unknown/0100000100FD000002000000755104000AA487A20000001F0AA487A200030001 001f
> > 13:37:51.255375 reply ok 32 access ERROR: Permission denied attr:
> 
> 'access' should never return 'Permission denied' so there is
> definitely something wrong here.  I was expected nfserr_acces rather
> than nfserr_perm...

Maybe a silly remark but:

	EACCES = Permission denied
	EPERM = Operation not permitted

-- 
Frank

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

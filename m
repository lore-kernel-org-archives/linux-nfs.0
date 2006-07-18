From: Neil Brown <neilb@suse.de>
Subject: Re: nfs problems with 2.6.18-rc1
Date: Wed, 19 Jul 2006 09:29:28 +1000
Message-ID: <17597.28376.805867.197599@cse.unsw.edu.au>
References: <priv$8d118c145575$b19af6759a@200607.shadow.banki.hu>
	<17594.51834.20365.820166@cse.unsw.edu.au>
	<priv$efbe06145615$0a94d550eb@200607.gmail.com>
	<priv$8d118c145627$464a3143cd@200607.shadow.banki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3Lf7-0007f5-E9
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 16:41:05 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G3Lf3-0003P2-Dj
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 16:41:02 -0700
To: Janos Farkas <chexum+dev@gmail.com>
In-Reply-To: message from Janos Farkas on Tuesday July 18
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

On Tuesday July 18, chexum+dev@gmail.com wrote:
> > On 2006-07-17 at 09:23:38, Neil Brown wrote:
> > > The standard answer for tracing nfs problems if 'tcpdump'.
> > > e.g. 
> > >   tcpdump -s 0 -w /tmp/trace host $CLIENT and host $SERVER and port 2049
> > > 
> > > that should show whether the error is coming from the server, or if
> > > the client is generating it all by itself.
> 
> Closing in, I have a dump between these two machines running 18-rc2 that
> has the error on the wire, but I'm not sure how much more would be
> relevant:

Hmmm...
Interesting, but confusing.
The filehandle of the directory seems to keep changing.  Maybe tcpdump
is showing too many bytes.  Access to the raw dump would help.

> 13:37:51.254708 access fh Unknown/0100000100FD000002000000755104000AA487A20000001F0AA487A200030001 001f
> 13:37:51.255375 reply ok 32 access ERROR: Permission denied attr:

'access' should never return 'Permission denied' so there is
definitely something wrong here.  I was expected nfserr_acces rather
than nfserr_perm...
The server logs at the same time would help a lot.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

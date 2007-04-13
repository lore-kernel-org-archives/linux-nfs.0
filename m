From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Does mountd/statd really need to listen on a
	privileged	port??
Date: Thu, 12 Apr 2007 20:05:15 -0400
Message-ID: <1176422715.6705.13.camel@heimdal.trondhjem.org>
References: <17950.44333.118970.276558@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc9I6-0007oI-2l
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 17:05:26 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+eujblksjCgileIQhvssTUh9/UtqwV4oI=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc9I5-0000Fn-UE
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 17:05:28 -0700
In-Reply-To: <17950.44333.118970.276558@notabene.brown>
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

On Fri, 2007-04-13 at 08:05 +1000, Neil Brown wrote:
> mountd/statd currently bind to privileged ports to listen for
> requests.
> 
> This is really a bad thing to do as there is no range of privilege
> ports that is guaranteed not to be assigned to some service.
> 
> sm-notify probably still needs a privileged port to send out
> notifications on, but that should be relatively short lived so
> hopefully isn't as much of a problem.
> 
> statd needs a privileged port to pass NOTIFY requests down to the
> kernel and that is probably the first really good reason I've seen to
> replace the rpc interface between lockd and statd.
> 
> But if get mountd and statd to default to choosing a non-reserved port
> for listening, that would at least decrease the chance that port 631
> will be stolen before cupsd gets to bind it.
> 
> But is there some reason that mountd/statd need a priv port that I
> haven't thought of?

I usually set statd to '--port 4047 --outgoing-port 4048' and mountd to
'--port 4046'. This more or less mirrors what is apparently the default
setup on NetApp filers (except the --outgoing-port bit) and has worked
pretty well for me.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

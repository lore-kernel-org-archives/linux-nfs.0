From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux nfs client tcp timeout
Date: Sat, 07 Apr 2007 17:17:51 -0400
Message-ID: <1175980671.20878.7.camel@heimdal.trondhjem.org>
References: <4cf2912c0704060910n33a269f3xcce6967a3abafc92@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Venkatesh KS <venkatesh.ks@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HaIIL-0000V4-1S
	for nfs@lists.sourceforge.net; Sat, 07 Apr 2007 14:18:01 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+tgHeA36kjEYDDXVImOiZaU/XO6Yh0sWc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HaIIM-0007jO-TK
	for nfs@lists.sourceforge.net; Sat, 07 Apr 2007 14:18:03 -0700
In-Reply-To: <4cf2912c0704060910n33a269f3xcce6967a3abafc92@mail.gmail.com>
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

On Fri, 2007-04-06 at 21:40 +0530, Venkatesh KS wrote:
> Hi,
> 
> I lost trace of a machine which was hung for 2 hours. The only
> culprits I can see are nfs write requests.
> The mount is for tcp, soft, retrans=4. Unfortunately I couldnt gather
> much information.
> 
> The file is opened O_SYNC and write sizes are average 4k. There could
> not have 
> been more than 40k worth writes against the server.
> 
> When I ran tests against a dead server, I saw timeouts of about 3
> minutes consistently.
> Only the first request took about 18mins to timeout.
> 
> So what is the timeout characteristics for tcp in linux nfs client and
> what parameters 
> can influence it?

man 5 nfs. You'll find a description of the 'timeo' and 'retrans'
options.

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

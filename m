From: Christian Robottom Reis <kiko@async.com.br>
Subject: Re: Performance expectations of NFS
Date: Thu, 25 Jan 2007 22:54:25 -0200
Message-ID: <20070126005425.GB29218@anthem.async.com.br>
References: <20070125193121.GA7267@anthem.async.com.br>
	<200701252350.22255.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: , Johan Dahlin <jdahlin@async.com.br>, nfs@lists.sourceforge.net
To: Bernd Schubert <bernd-schubert@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAFMR-0000rt-6p
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 16:54:35 -0800
Received: from frodo.hserus.net ([204.74.68.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAFMR-0000zY-Uk
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 16:54:37 -0800
In-Reply-To: <200701252350.22255.bernd-schubert@gmx.de>
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

On Thu, Jan 25, 2007 at 11:50:21PM +0100, Bernd Schubert wrote:
> Hi Christian,
> 
> >   0:05  - Server: locally on RAID-5
> >   0:06  - Client: copying from NFS mount to tmpfs
> >   2:31  - Client: Copying from NFS mount to NFS mount
> >           (i.e., the simple command above)
> >   3:30  - Client: Copying from NFS mount to NFS mount over an existing
> >           tree.
> >   5:08  - Client: Copying from tmpfs to NFS mount
> >   0:48  - Client: Deleting copy of tree on NFS mount
> 
> I guess your exports has the "sync" option or your didn't set  async or sync 
> at all (sync is then the default)? Can you repeat the test again using the 
> async option? But please, also read carefully the explanations of "man 5 
> exports" about this topic. 

This /was/ using the async option. Using sync causes the times to worsen
by about 70% (so the NFS to NFS copy takes about 5 minutes).

> Just for fun, take ethereal and capture some data, once with the async and 
> once with the sync option. Now have a look how much time each operation of 
> the nfs client takes before it gets confirmed by the server. Especially look 
> at the commit calls, once with sync and once with async option.

Yeah, that's a great idea; I should do that tomorrow.

> I guess if one could convince the nfs clients to reduce the number of commit 
> calls, write operations would be much much faster. Don't know if that is 
> possible at all, though.

I get the feeling that the real bottleneck is synchronous file
creation. What I would like to understand is whether this is done for
reliability or to preserve filesystem semantics.
-- 
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

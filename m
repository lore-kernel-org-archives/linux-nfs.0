From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cel's patches under development
Date: Tue, 10 Apr 2007 15:32:19 -0400
Message-ID: <1176233539.309.27.camel@heimdal.trondhjem.org>
References: <460852BB.4080503@oracle.com>
	<200704101722.13798.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbM4s-0003Ty-VV
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 12:32:31 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18qQ6z8dVObtremjkfNGpjoirTWwPjI+A4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HbM4v-0003SZ-3V
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 12:32:33 -0700
In-Reply-To: <200704101722.13798.olaf.kirch@oracle.com>
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

On Tue, 2007-04-10 at 17:22 +0200, Olaf Kirch wrote:
> Hi,
> The approach I'm trying is to leave the data in skb's for as long as it's
> practical, and copy data to the page cache in the XDR decode routines.
> In order to hide the skb mechanics, there's an rpc_data object that
> encapsulates this. It looks a little awkward, but Chuck complained
> about layering violations so I tried this instead.

I'm a bit wary of this. skbs are usually allocated from the ATOMIC pool
which is a very limited resource: their lifetime really wants to be as
short as possible. Won't this basically end up aggravating an already
nasty situation w.r.t. our behaviour when under memory pressure?

Also, what about stuff like RDMA, which doesn't need this sort of
mechanism in order to get things right?

Finally, will we need to keep writing these very complex handlers for
every new protocol that we want to add (e.g. IPv6, IPoIB, ...)?

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

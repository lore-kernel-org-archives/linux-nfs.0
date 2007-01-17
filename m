From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: CVE-2006-5158 -- is a NULL nfs_lockowner->owner
	field	legal?
Date: Wed, 17 Jan 2007 13:21:35 -0500
Message-ID: <1169058095.6523.1.camel@lade.trondhjem.org>
References: <200701171639.l0HGdxwg025600@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: staubach@redhat.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7FQY-0001p9-St
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 10:22:27 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/V1LcQ0XKgeda2yfpuVsjAGkC4+Jdi6E8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7FQN-0004dK-68
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 10:22:28 -0800
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: <200701171639.l0HGdxwg025600@dantu.rdu.redhat.com>
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

On Wed, 2007-01-17 at 11:39 -0500, Jeff Layton wrote:
> I've been looking over an issue that related to CVE-2006-5158 (which is a
> NULL pointer dereference in nlmclnt_mark_reclaim). It looks like the only
> way it's possible to get in this situation is when the kmalloc in
> nlm_find_lockowner returns NULL. If this occurs, it seems like that should
> be an error condition and we should abort whatever operation is occurring.
> 
> So my question is -- should a NULL "owner" field in an nfs_lockowner struct
> even be considered legal? If not, would something like the patch below be
> reasonable?

No. NULL owner fields are not legal, and we should indeed abort the lock
call whenever that occurs.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

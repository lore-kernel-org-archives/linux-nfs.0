From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 16:46:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097851608.5558.15.camel@lade.trondhjem.org>
References: <20041015095840.GA22992@suse.de>
	 <20041015100703.GA27307@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CITMM-0003qD-TO
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 07:47:10 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CITMH-0001Hw-Dz
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 07:47:10 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041015100703.GA27307@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 fr , 15/10/2004 klokka 12:07, skreiv Olaf Kirch:
> On Fri, Oct 15, 2004 at 11:58:40AM +0200, Olaf Kirch wrote:
> > I don't know why this change was made. The patch below simply reverts
> > these two hunks; maybe there's a better solution involving LOCK_USE_CLN=
T
> > the way it's used for F_GETLK at the moment.
>=20
> I forgot to add the patch. Below there are two possible fixes.
>=20
>  fix1: just revert the changes
>=20
>  fix2: use LOCK_USE_CLNT for all locking operations if mounted nolock.
>
> The second one is probably better...

LOCK_USE_CLNT is better than "fix1" in that it actually does the right
thing. That said, it is still a hack, and since there is no reason to
keep it around any longer, it really should go.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

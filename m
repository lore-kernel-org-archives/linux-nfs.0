From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Mount version older than kernel: 4 vs. 6
Date: Wed, 04 Aug 2004 14:34:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091655249.3956.41.camel@lade.trondhjem.org>
References: <4110DB81.4020103@bio.ifi.lmu.de>
	 <20040804130419.GI4471@suse.de> <4110E3C3.3050705@bio.ifi.lmu.de>
	 <20040804135130.GL4471@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsTPc-00012G-FE
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 14:35:04 -0700
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BsTPc-0003e5-1M
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 14:35:04 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040804135130.GL4471@suse.de>
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

P=E5 on , 04/08/2004 klokka 06:51, skreiv Olaf Kirch:
> On Wed, Aug 04, 2004 at 03:25:23PM +0200, Frank Steiner wrote:
> > I see. But then it looks like a bug to me that the code in the inode.c
> > is comparing the "NFS version" (4, in data->version) against the
> > "NFS kernel mount struct" (6, in NFS_MOUNT_VERSION). That doesn't
> > make sense, does it?
>=20
> data->version _is_ the API version. Your mount binary currently
> uses API version 4. The kernel supports up to API version 6
> (which add NFSv4 support).

Nope. NFSv4 uses an entirely separate mount structure.

For the NFSv2/v3 mount structure, API version 5 adds RPCSEC_GSS the
secure RPC model. API version 6 adds support for passing security
context information down for use by LSM/SELinux/...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

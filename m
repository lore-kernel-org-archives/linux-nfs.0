From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3 UID/GID mapping
Date: Thu, 22 Apr 2004 13:25:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040422172512.GE12400@fieldses.org>
References: <m3vfjsxsky.fsf@pc213.belcaf.minsk.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGhwx-0008Qc-W2
	for nfs@lists.sourceforge.net; Thu, 22 Apr 2004 10:25:23 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BGhwx-0008Kp-J0
	for nfs@lists.sourceforge.net; Thu, 22 Apr 2004 10:25:23 -0700
To: "Ed V. Bartosh" <ed@sam-solutions.net>
In-Reply-To: <m3vfjsxsky.fsf@pc213.belcaf.minsk.by>
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

On Thu, Apr 22, 2004 at 12:36:13PM +0300, Ed V. Bartosh wrote:
> Here is the NFSv3 uid/gid mapping implementation (both kernel and
> nfs-utils parts). Userspace part uses idmap daemon from CITI NFSv4, 
> so the NFSv4 patches are required.

Just out of curiosity:
	* This does the server side only.  Have you looked at the client side
	  at all?
	* What sort of applications are you considering for this?

> Look at this, please. Any kind of feedback will be appreciated.

Do you also need to do map the id's in nfs3xdr.c:xdr_encode_setattr() and
xdr_decode_fattr()?

Is IDMAP_UID_NONE really needed, or could you just use an ENOENT return?

We need to figure out a way to do this without duplicating so much code
from nfs4idmap.c.

Also note some of that code is wrong.  (See the nfsd_idmap patches in
http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.6-rc1-3/).

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

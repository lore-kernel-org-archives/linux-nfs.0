From: Ion Badulescu <ionut@badula.org>
Subject: Re: Disabling Symbolic Link Content Caching in NFS Client
Date: Mon, 2 Jun 2003 16:37:23 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200306022037.h52KbNVh012849@buggy.badula.org>
References: <2BB7146B38D9CA40B215AB3DAAE24C080BA4F3@blr-m2-msg.wipro.com>
Cc: <trond.myklebust@fys.uio.no>, <indou.takao@jp.fujitsu.com>,
   <ezk@cs.sunysb.edu>, <viro@math.psu.edu>, <davem@redhat.com>,
   <nfs@lists.sourceforge.net>, <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-43524450.dyn.optonline.net ([67.82.68.80] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Mw3r-0001Vw-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Jun 2003 13:37:44 -0700
To: "Vivek Goyal" <vivek.goyal@wipro.com>
In-Reply-To: <2BB7146B38D9CA40B215AB3DAAE24C080BA4F3@blr-m2-msg.wipro.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, 28 May 2003 16:39:36 +0530, Vivek Goyal <vivek.goyal@wipro.com> wrote:

> I was following previous discussions in the mailing list and found that
> caching mechanism affected hlfsd behavior. It looks like the problem was
> resolved by updating mtime on every access. But still caching will lead
> to a problem if two accesses are taking place in same jiffy.

Yes, because the the nfs client is broken in this respect. noac 
should mean noac, but the nfs client will still cache attributes if the 
second access happens within the same jiffy as the previous access which 
updated the attribute cache.

Replacing a couple of time_after() calls with time_after_eq() calls 
fixes the issue, at least for hlfsd. Of course, running with noac might 
be very much unacceptable if all you want is to avoid caching symlinks.

> We are considering following design strategy to implement the parameter.
> 
> 1. Make nfs_symlink_caching dynamically tunable using /proc and sysctl
> interface.

No. Do it on a per-mount basis, like the other OS's do.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

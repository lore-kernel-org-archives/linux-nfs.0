From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH nfsd] ignore chmod calls on symlinks
Date: Tue, 12 Jul 2005 10:52:56 +0200
Message-ID: <20050712085256.GA20612@suse.de>
References: <20050711110635.GM27163@suse.de> <42D26A3F.7030703@redhat.com> <20050711125918.GT27163@suse.de> <42D26EB6.3090301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsGVi-0005iD-N7
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 01:53:02 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DsGVh-0005b4-Hv
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 01:53:02 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42D26EB6.3090301@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, Jul 11, 2005 at 09:05:58AM -0400, Peter Staubach wrote:
> So, the nfsd layer is not doing what the vfs layer on the system is already
> for callers into the file systems?

Yes. sys_chmod will dereference any symlinks, so the situation is
entirely different.

If nfsd tries to chmod a symlink on eg reiserfs, it will get an
EOPNOTSUPP or something like this.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

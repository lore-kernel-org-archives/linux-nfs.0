From: Scott Leerssen <scott@leerssen.com>
Subject: Re: nfs root directory security
Date: 17 Jun 2003 23:38:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055907497.28760.10.camel@lodge.leerssen.com>
References: <1055888933.16259.54.camel@sleerssen.racemi.com>
	 <16111.42521.693155.783206@gargle.gargle.HOWL>
	 <1055904839.28760.4.camel@lodge.leerssen.com>
	 <16111.57576.494626.387349@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tisch.mail.mindspring.net ([207.69.200.157])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19STyX-00047c-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 20:51:09 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16111.57576.494626.387349@gargle.gargle.HOWL>
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

On Tue, 2003-06-17 at 23:47, Neil Brown wrote:
> On  June 17, scott@leerssen.com wrote:
> > 
> > Here's a specific example.  Let's say you have a data center and use
> > network attached storage to maintain filesystems for all of your
> > customers.  Since all customers have access to the NAS, and all have
> > their own box with root access, it's not too difficult to go poking
> > around on the NAS to find other folks' stuff.  One obvious way to deal
> > with this is to have separate exported filesystems for each customer,
> > however, that becomes a huge maintenance hassle if you have a few
> > hundred customers.  This feature allows you to maintain all the
> > filesystems under one NFS root, while hiding the filesystems of other
> > customers.
> 
> 
> So you want to hide the names from people who don't know them.
> Sure removing read permission is enough. Without read permission you
> cannot "ls" and so cannot find the names.

The point is that there's nothing stopping the client from them from
mounting the directory.  The current NFS implementation permits it, and
it's a lot easier to catch someone repeatedly attempting to find mount
points than it is to find someone who just attempts to cd into a
directory below something that they have mount access to.

> 
> Alternately just export the subdirectories rather than the parent.
> Export different subdirectories to different clients.
> 

Try maintaining that for a few hundred (heck even a few dozen) clients.

-- 
Scott Leerssen <scott@leerssen.com>



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Scott Leerssen <scott@leerssen.com>
Subject: Re: nfs root directory security
Date: 17 Jun 2003 22:54:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055904839.28760.4.camel@lodge.leerssen.com>
References: <1055888933.16259.54.camel@sleerssen.racemi.com>
	 <16111.42521.693155.783206@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from maynard.mail.mindspring.net ([207.69.200.243])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19STHh-0004u6-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 20:06:53 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16111.42521.693155.783206@gargle.gargle.HOWL>
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

On Tue, 2003-06-17 at 19:36, Neil Brown wrote:
> On  June 17, scott@leerssen.com wrote:
> > Attached is a patch for nfs-utils-1.0.1-2.9 (RedHat) that adds a bit of
> > security and ease of use for exported filesystems that have lots of
> > users in lots of subdirectories.
> > 
> > What it does is disallow nfs clients from mounting a directory that is
> > marked execute only (chmod 0111), controlled by an option
> > "root_mnt_orig".  This is handy if one has a constantly changing
> > hierarchy of subdirectories where the client is the only one who knows
> > where to look for his stuff.  Consider a directory structure that looks
> > like:
> > 
> > /A/B/C/123
> > /A/B/C/456
> > /A/B/C/789
> > 
> > If A, B and C are mode 0111, the nfs client must directly mount 123,
> > 456, or 789.  OK, this is a kind of lame example, but one can easily add
> > some obscurity to the directory structure under /A and see how
> > effectively this hides NFS mount points and adds some ease of use when
> > maintaining a TON of mount points.
> 
> Hi.
> I'm cannot see how this adds any significant security.
> 
> If you only want the client to mount certain bits, and the clients
> know which bits to mount, then just mount those bits on the client.
> 
> Given that you allow the clients to mount any directories that they
> have read access to, how does it hurt to allow them to mount parents
> that they don't have read access to?
> I can see that you don't want them to, but surely that is a client
> configuration issue, not a server issue.

Here's a specific example.  Let's say you have a data center and use
network attached storage to maintain filesystems for all of your
customers.  Since all customers have access to the NAS, and all have
their own box with root access, it's not too difficult to go poking
around on the NAS to find other folks' stuff.  One obvious way to deal
with this is to have separate exported filesystems for each customer,
however, that becomes a huge maintenance hassle if you have a few
hundred customers.  This feature allows you to maintain all the
filesystems under one NFS root, while hiding the filesystems of other
customers.


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

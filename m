From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: 2.4 vs 2.6
Date: Wed, 14 Jun 2006 11:29:31 +1000
Message-ID: <1150248571.22282.1450.camel@hole.melbourne.sgi.com>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
	<17530.36039.227704.325645@cse.unsw.edu.au>
	<20060529160236.GC6832@fieldses.org> <20060530011208.GB12818@sgi.com>
	<20060530015918.GA27940@fieldses.org>
	<17550.12582.742528.454837@cse.unsw.edu.au>
	<20060613204225.GB26315@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	mehta kiran <kiranmehta1981@yahoo.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqKCY-0001Dr-Kq
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 18:29:46 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FqKCX-0001SA-Iq
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 18:29:46 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060613204225.GB26315@fieldses.org>
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

On Wed, 2006-06-14 at 06:42, J. Bruce Fields wrote:
> On Tue, Jun 13, 2006 at 01:29:42PM +1000, Neil Brown wrote:
> >    If a request arrives from a host which is in both 'somehosts' and
> >    'otherhosts', then what name do you give to the kernel for that IP
> >    address?
> >    We currently say the IP address maps to 
> >           @somehosts+@otherhosts
> >    (or something like that) and then tell the kernel any of the
> >    following as required:
> >           /export1 @somehosts+@otherhosts  -> rw,root_squash
> >           /export1 @somehosts  -> rw,root_squash
> >           /export2 @somehosts+@otherhosts  -> ro,no_root_squash
> >           /export2 @otherhosts  -> ro,no_root_squash
> 
> The kernel could of course just split these plus+separated+name+lists
> itself before mapping to export options.  But I guess the point is that
> in cases such as the above there's a policy decision that's better made
> in userspace.  OK.

There are a couple more considerations.

First, the list of IP addresses to which a netgroup maps can be
quite large; we've seen problems on customer sites which had
netgroups with over 8K entries.  Getting this amount of data
into the kernel in an exportfs operation is problematical.

Second, the membership of a netgroup can be controlled on a NIS
server and so can vary behind the kernel's back, so that the list
of addresses in the kernel becomes stale.  Of course this is both
most likely to happen and most painful with the same customers who
have the enormous netgroups.

Both of these mean that enumerating netgroups and shoving the
results into the kernel isn't practical.   The only real solution
here is to do a NIS query in userspace on mount.  Thanks to NFSv3's
mythical "statelessness" this really means on first NFS call from
a new host.  Hence you need an upcall.

There are only two criticisms I would make of Linux' upcall design.

First, Linux uses a wacky special-purpose filesystem.  Solaris and
IRIX use a normal RPC to a special RPC program number implemented
in mountd, using the existing RPC client code which is already needed
in the server to initiate lockd callbacks.  This reduces code
complexity in the kernel, and means you can watch the upcall traffic
with wireshark (or whatever ethereal is called this week) or snoop
instead of strace on mountd.  But whatever, it mostly works now.

Second, rpc.mountd is single-threaded, and needs to do a blocking
reverse hostname lookup on every mount and needs to respond to at
least one upcall shortly afterward.  When you have a thousand
compute cluster nodes all trying to mount in the same second, this
gets to be something of a problem.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

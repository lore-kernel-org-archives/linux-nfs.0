From: Neil Brown <neilb@suse.de>
Subject: Re: 2.4 vs 2.6
Date: Tue, 13 Jun 2006 13:29:42 +1000
Message-ID: <17550.12582.742528.454837@cse.unsw.edu.au>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
	<17530.36039.227704.325645@cse.unsw.edu.au>
	<20060529160236.GC6832@fieldses.org>
	<20060530011208.GB12818@sgi.com>
	<20060530015918.GA27940@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	Vijay Chauhan <kernel.vijay@gmail.com>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpzbP-0003u2-R9
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:30:03 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FpzbO-0006ag-8K
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:30:04 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Monday May 29
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

On Monday May 29, bfields@fieldses.org wrote:
> On Tue, May 30, 2006 at 11:12:08AM +1000, Greg Banks wrote:
> > On Mon, May 29, 2006 at 12:02:36PM -0400, J. Bruce Fields wrote:
> > > I don't see why this *has* to be done on demand, though, unless the
> > > export table is extremely large and only sparsely used.  I might be
> > > missing something.
> > 
> > /mnt/data *.domain1.company.com(ro,sync) *.domain2.company.com(rw,sync)
> 
> I realize that the ip->client-name mapping is too large to preload into
> the kernel.
> 
> It's the (path, client-name) --> export options that I wonder about.

Having the mapping permanently in the kernel rather than filled in on
demand would mean that:

 - the filesystem has to be mounted the whole time, and we cannot do
   any on-demand mounting (based on fsid) - not that we currently do.
   This is a fairly small point however.
 - the client-names would need to be known in advance.  It seems
   obvious that they would be, but they aren't.
   What do you do if you get a request from an IP address that matches
   several of the tags in /etc/exports ? e.g.
      /export1 @somehosts(rw,root_squash)
      /export2 @otherhosts(ro,no_root_squash)

   If a request arrives from a host which is in both 'somehosts' and
   'otherhosts', then what name do you give to the kernel for that IP
   address?
   We currently say the IP address maps to 
          @somehosts+@otherhosts
   (or something like that) and then tell the kernel any of the
   following as required:
          /export1 @somehosts+@otherhosts  -> rw,root_squash
          /export1 @somehosts  -> rw,root_squash
          /export2 @somehosts+@otherhosts  -> ro,no_root_squash
          /export2 @otherhosts  -> ro,no_root_squash
          
Hopefully you can see that giving a full (path, client-name ) ->
export mapping the kernel in advance is not practical.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

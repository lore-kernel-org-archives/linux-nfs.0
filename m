From: Neil Brown <neilb@suse.de>
Subject: Re: NFS and partitioned md
Date: Mon, 21 Aug 2006 12:29:46 +1000
Message-ID: <17641.6810.964679.839075@cse.unsw.edu.au>
References: <1151355145.4460.16.camel@archon.smoula-in.net>
	<17568.31894.207153.563590@cse.unsw.edu.au>
	<1151432312.11996.32.camel@reaver.netbox-in.cz>
	<17571.19699.980491.970386@cse.unsw.edu.au>
	<44BD2A29.8060405@dgreaves.com>
	<1153253099.26360.3.camel@archon.smoula-in.net>
	<17598.52873.335796.13969@cse.unsw.edu.au>
	<20060720090736.GB1408@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Greaves <david@dgreaves.com>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org, Martin Filip <bugtraq@smoula.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GEzYV-0000pn-Nn
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:30:23 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GEzYU-0003Ki-JU
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:30:24 -0700
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: message from Frank van Maarseveen on Thursday July 20
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

On Thursday July 20, frankvm@frankvm.com wrote:
> On Thu, Jul 20, 2006 at 10:30:01AM +1000, Neil Brown wrote:
> > On Tuesday July 18, bugtraq@smoula.net wrote:
> > > Hi,
> > > 
> > > my solution was to use fsid parameter for exports... maybe some other
> > > mechanism for selecting fsids could be created instead of fsid = device
> > > minor
> > 
> > Yes.  Better management of fsid is on my wishlist for nfs-utils.
> > Unfortunately I haven't had any really clever ideas yet.
> 
> I'd like to "virtualize" exports such that it is possible to transplant
> disks/partitions from one machine into another without having to bother
> with device numbering. One step in that direction is to derive the fsid
> from an IP address. The server machine needs an additional IP address
> for every export entry. This IP address is determined by deriving
> a hostname from the last pathname component of the export entry and
> resolving it. E.g. something like:
> 
> /etc/exports:
> 	/exported/path/name	*(rw,sync,no_root_squash,no_subtree_check,fsid="nfs-%s")
> 
> This would set the fsid to the IP address of host "nfs-name".

(I'm catching up on only mail - seems I missed this...)

I think that is very specific to your particular setup, but there
certainly is bits of a possibly usable idea in there.

As the fsid is limited in size, we really need some sort of lookup
table somewhere to make between fsid and some arbitrary name for the
filesystem.
You are suggesting using the DNS for this lookup.  
Maybe that make sense..... maybe.

My leaning is to make it somebody-elses-problem by enabling a
call-out.

i.e. we declare a program that will be used for mapping between fsid
and mount point.

So: when parsing /etc/exports, if we find "fsid=??", we run the
program passing the path get an fsid.
When we get a filehandle with an unknown fsid, we pass it to the
program which will return a pathname (possible auto-mounting something
or whatever).

You could quite easily make a script that does the mapping you
require.

Maybe one day...

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

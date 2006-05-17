From: Neil Brown <neilb@suse.de>
Subject: Re: Annoying exports problem
Date: Thu, 18 May 2006 09:33:14 +1000
Message-ID: <17515.45754.770170.922929@cse.unsw.edu.au>
References: <17514.49131.206204.982852@cse.unsw.edu.au>
	<C09011BA.32978%jeremy@smokehabanos.com>
	<17514.50440.625251.136574@cse.unsw.edu.au>
	<20060517192622.GF1206@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy <jeremy@smokehabanos.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FgVWR-00073k-Ba
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 16:33:43 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FgVWR-0000yN-8f
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 16:33:43 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FgVWP-000242-W1
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 16:33:43 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Wednesday May 17
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

On Wednesday May 17, bfields@fieldses.org wrote:
> On Wed, May 17, 2006 at 04:39:04PM +1000, Neil Brown wrote:
> > On Tuesday May 16, jeremy@smokehabanos.com wrote:
> > > I actually got it to work in the little time since my initial post.  The
> > > only way I could do it was to export both the root filesystem and the
> > > individual directories within the /storage.  So it looks like this:
> > > 
> > > /storage       *(rw,no_root_squash,async)
> > > /storage/space0       *(rw,no_root_squash,async,no_subtree_check,nohide)
> > > /storage/space1       *(rw,no_root_squash,async,no_subtree_check,nohide)
> > > /storage/space2       *(rw,no_root_squash,async,no_subtree_check,nohide)
> > > /storage/space3       *(rw,no_root_squash,async,no_subtree_check,nohide)
> > > /storage/space4       *(rw,no_root_squash,async,no_subtree_check,nohide)
> > > /storage/space5       *(rw,no_root_squash,async,no_subtree_check,nohide)
> > 
> > This works too
> > Putting 'crossmnt' on the first line should remove the need for the
> > remaining lines.
> 
> It should remove the need for the nohide option on those lines, but I
> think the export lines will still be required.  Is that not how it's
> meant to work?

Not sure... it is a while since I have looked at that code.

But maybe the key issue is not so much how it is "meant to work", but
how we "want it to work".
I suspect it would be very valuable and no harm to allow 

   /storage       *(rw,no_root_squash,async,crossmnt)

to export everything below /storage, including other filesystems.

I've put it on my todo list to look into one day.

NeilBrown


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

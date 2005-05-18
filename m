From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: NFS server problem with kernel 2.6.8.1
Date: Wed, 18 May 2005 13:37:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0505181328230.6834@chaos.egr.duke.edu>
References: <428A57C1.7070807@pauli.utmb.edu>  <Pine.LNX.4.58.0505171649400.6834@chaos.egr.duke.edu>
 <1116364789.21501.13.camel@pauli.utmb.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYSU3-0007Jt-Gy
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 10:37:27 -0700
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYSU2-0004kR-U6
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 10:37:27 -0700
To: Yuan Xu <yuan@pauli.utmb.edu>
In-Reply-To: <1116364789.21501.13.camel@pauli.utmb.edu>
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

Please keep replies on the list so that all can chip in.

On Tue, 17 May 2005 at 4:19pm, Yuan Xu wrote

> All I did was upgrading via RHN and yes I was running Enterprise AS3
> EHEL3 before. I even did not know I got a new kernel till I booted the
> machine after running RHN. Believe me that 2.6.x was what I got from
> running up2date. 

I'm sorry, but no, you didn't.  There isn't and there never will be a 2.6 
kernel release from Red Hat for RHEL3.

> > > When I was running  kernel  2.4.21-27.0.2.ELsmp my nfs server worked 
> > > fine and after upgrading to 2.6.x via Redhat RHN my NFS sever no longer 
> > > works.

That doesn't surprise me, as there are lots of differences between 2.4 and 
2.6 and RHEL3 isn't a 2.6 ready distro out of the box.

> > The first kernel is from RHEL3, which has no option for a 2.6 kernel via 
> > RHN.  Did you try to up2date the server to RHEL4?  In general, that is not 
> > recommended.
> No, I did not try to upgrade to RHEL4 via up2date since I support
> expired not long ago. It sees to me FC3 works much better.
> I do not want to go into FC3 on this machine b/c it loaded with lots of
> stuff (3rd party programs). Just want to make NFS server work again
> > 
> > > Right now the NFS server is running kernel 2.6.8.1 SMP, x86_64 and I can 
> > 
> > That's not a Red Hat kernel.
> So it is a FC3 kernel?

No.  2.6.8.1 is a vanilla kernel, i.e. from kernel.org.  Someone else must 
have installed that, b/c RHN sure didn't.  Your best bet is to move the 
system back to the most recent official RH kernel you have access to (the 
most recent RHEL3 kernel is 2.4.21-27.0.4.EL).

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

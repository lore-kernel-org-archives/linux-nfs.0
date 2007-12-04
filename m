From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [NFS] nfs-utils crossmnt/fsid bug
Date: Tue, 04 Dec 2007 09:42:44 -0800
Message-ID: <1196790164.1215.9.camel@dyn9047022153>
References: <20070905204628.GD29582@fieldses.org>
	<18246.16373.177320.570040@notabene.brown>
	<1196722262.1215.5.camel@dyn9047022153>
	<18260.43206.943331.889058@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, ffilz@us.ibm.com,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57365 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745AbXLDSAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2007 13:00:16 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Izc42-0000cU-5S
	for linux-nfs@vger.kernel.org; Wed, 05 Dec 2007 05:00:10 +1100
In-Reply-To: <18260.43206.943331.889058-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2007-12-04 at 12:09 +1100, Neil Brown wrote:
> On Monday December 3, ffilzlnx@us.ibm.com wrote:
> > On Fri, 2007-11-23 at 13:50 +1100, Neil Brown wrote:
> > > Does this (untested, but it compiles) patch seem right?
> > 
> > In testing security negotiation, I ran into this problem. I've tried
> > this patch and it doesn't seem to be working right. My exports file is:
> > 
> > /export/home    gss/krb5i(nohide,insecure,no_subtree_check,no_root_squash,async,rw)
> > /export/home    gss/krb5p(nohide,insecure,no_subtree_check,no_root_squash,async,rw)
> > /export         gss/krb5(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)
> > /export         gss/krb5i(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)
> 
> You don't need the patch for this exports file.  It is only relevant
> when the underlying filesystem is not explicitly exported, so the
> export flags a deduced implicitly.
> 
> So - this is a separate issue.

Ah, ok.
 
> > From the client I execute:
> > 
> > mount -overs=4,sec=krb5 elm3a19.beaverton.ibm.com:/ /mnt 
> > ls -l /mnt/home
> 
> ... and what happens?

This is what I get:

# mount -overs=4,sec=krb5 elm3a19.beaverton.ibm.com:/ /mnt
# ls -l /mnt
total 32
-rw-r--r--    1 nobody   nobody           32 Nov  7 15:00 foo
drwxr-xr-x   19 nobody   nobody         4096 Dec  3 14:40 home
drwxr-xr-x    2 nobody   nobody         4096 Nov  2 17:51 homw2
# ls -l /mnt/home
total 32
-rw-r--r--    1 nobody   nobody           32 Nov  7 15:00 foo
drwxr-xr-x   19 nobody   nobody         4096 Dec  3 14:40 home
drwxr-xr-x    2 nobody   nobody         4096 Nov  2 17:51 homw2
# ls -l /mnt/homw2  
total 0
-rw-r--r--    1 nobody   nobody            0 Nov  2 17:51 foo
# umount /mnt

This is from an AIX client, however, with the new format exports with
the sec= export option, the AIX client works just fine (given the patch
I submitted previously).

Frank Filz


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


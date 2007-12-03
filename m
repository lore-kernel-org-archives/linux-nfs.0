From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [NFS] nfs-utils crossmnt/fsid bug
Date: Mon, 03 Dec 2007 14:51:02 -0800
Message-ID: <1196722262.1215.5.camel@dyn9047022153>
References: <20070905204628.GD29582@fieldses.org>
	<18246.16373.177320.570040@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, ffilz@us.ibm.com,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41316 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333AbXLCXN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 18:13:26 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1IzKTb-0007av-Ac
	for linux-nfs@vger.kernel.org; Tue, 04 Dec 2007 10:13:23 +1100
In-Reply-To: <18246.16373.177320.570040-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2007-11-23 at 13:50 +1100, Neil Brown wrote:
> On Wednesday September 5, bfields@fieldses.org wrote:
> > With an exports entry like
> > 
> > 	/exports *.citi.umich.edu(rw,crossmnt,fsid=0)
> > 
> > and some other stuff mounted under /exports, I get an odd situation
> > where listing /exports/submnt/ shows me the contents of /exports/.
> > 
> > I looks to me like what's happening is that the new code to
> > automatically export filesystems under crossmnt exports is exporting
> > those directories with the fsid option turned on, with the result that
> > the root of each of those subdirectories ends up with the same
> > filehandle as the root of /exports, and the hilarity ensues.  But I
> > haven't tried a patch yet.
> > 
> > Does that make sense?  I assume we should just clear the fsid flag on
> > submounts, as it's never going to make sense, and leave the logic
> > otherwise intact.
> > 
> > --b.
> 
> Thanks for noticing and reporting this.
> 
> Does this (untested, but it compiles) patch seem right?

In testing security negotiation, I ran into this problem. I've tried
this patch and it doesn't seem to be working right. My exports file is:

/export/home    gss/krb5i(nohide,insecure,no_subtree_check,no_root_squash,async,rw)
/export/home    gss/krb5p(nohide,insecure,no_subtree_check,no_root_squash,async,rw)
/export         gss/krb5(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)
/export         gss/krb5i(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)

>From the client I execute:

mount -overs=4,sec=krb5 elm3a19.beaverton.ibm.com:/ /mnt 
ls -l /mnt/home

I added some debug logging, and I see the different_fs path being taken
on the /export/home. I'm wondering, could there be a kernel part to this
also?

Thanks

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


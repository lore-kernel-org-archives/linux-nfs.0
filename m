From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/12] text-based mount.nfs:
Date: Fri, 12 Oct 2007 09:04:49 +1000
Message-ID: <18190.44049.604497.746871@notabene.brown>
References: <20071008155407.15051.60775.stgit@manray.1015granger.net>
	<18186.56139.301135.961540@notabene.brown>
	<5847045D-72E9-4322-AB08-F8952C26AA44@oracle.com>
	<18189.32027.462332.151295@notabene.brown>
	<470D8F45.8020202@oracle.com>
	<18189.39095.274290.825015@notabene.brown>
	<3025DF8E-F29F-48BA-BCF3-F9530776A659@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ig75P-0006j3-2L
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 16:05:01 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ig75S-0005Gm-Pc
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 16:05:04 -0700
In-Reply-To: message from Chuck Lever on Thursday October 11
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday October 11, chuck.lever@oracle.com wrote:
> On Oct 10, 2007, at 11:29 PM, Neil Brown wrote:
> >
> > Two key fixes:
> >   1/ Don't give up probing if we get RPC_PROGVERSMISMATCH.
> >   2/ Don't set pm_vers if it isn't set in mtab.  Leave it at zero so
> >      the probe routines get a chance to do the right thing.
> 
> I think that's the right thing to do.
> 
> >    An awkwardness here was we were overloading the meaning of
> >         pm_vers == 0
> >    In some contexts it means "Has not been explicitly set, probe".
> >    In other contexts it means "Mountd is not used (due to NFSv4)".
> >
> >    I introduced '63356' for the second meaning, but would rather a
> >    cleaner approach.
> 
> That shouldn't be necessary.  Kevin and I just added a bit of logic  
> to prevent the do_nfs_unmount() call for "nfs4" file systems (see nfs- 
> utils commit 97fed306).
> 
> That ought to make your patch much simpler, overall.
> 
> >    Maybe we don't need the second meaning, as the 2/3 versus 4
> >    distinction is present in mnt_type so we never call do_nfs_umount
> >    for a v4 mount.  Is that true?
> 
> Yep!
> 
> Actually you could make it clear that do_nfs_unmount() is not for v4  
> by renaming it do_nfs_unmount23() or something like that.
> 

Thanks for the feedback.  I've removed the v4 handling from
do_nfs_umount and nfs_call_umount, and it does the right thing for
this case now.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

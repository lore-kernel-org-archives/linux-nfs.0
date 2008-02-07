From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Thu, 7 Feb 2008 14:44:00 +1100
Message-ID: <18346.32384.780598.485949__17631.5290773802$1202355896$gmane$org@notabene.brown>
References: <1201726404.2976.8.camel@localhost.localdomain>
	<20080205102955.GA28347@infradead.org>
	<1202233464.12188.43.camel@localhost.localdomain>
	<20080206180850.GD3475@duck.suse.cz>
	<1202331482.2727.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>
To: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48334 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754102AbYBGDoT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 22:44:19 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JMxgP-00015V-Pv
	for linux-nfs@vger.kernel.org; Thu, 07 Feb 2008 14:44:17 +1100
In-Reply-To: message from Rasmus Rohde on Wednesday February 6
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday February 6, rohde-3mLe3WyXyAE@public.gmane.org wrote:
> > > +	dotdot.d_name.name = "..";
> > > +	dotdot.d_name.len = 2;
> > > +
> > > +	lock_kernel();
> > > +	if (!udf_find_entry(child->d_inode, &dotdot, &fibh, &cfi))
> > > +		goto out_unlock;
> >   Have you ever tried this? I think this could never work. UDF doesn't have
> > entry named .. in a directory. You have to search for an entry that has
> > in fileCharacteristics set bit FID_FILE_CHAR_PARENT. Maybe you could
> > hack-around udf_find_entry() to recognize .. dentry and do the search
> > accordingly.
> Probably not. I just tested that I could read files and navigate the
> directory structure. However looking into UDF I think you are right - it
> will fail.
> I have extended udf_find_entry() to do an explicit check based on
> fileCharacteristics as you propose.
> How do I actually test this case?

 - Mount the filesystem from the server.
 - 'cd' a few directories down into the filesystem.
 - reboot the server(1)
 - on the client 'ls -l'.

(1) A full reboot isn't needed.  Just unexport, unmount, remount,
    re-export on the server.

alternately, use a non-linux client and cd down into the filesystem
and
    ls -l ..

NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] DefineSimpleCache macro problem
Date: Fri, 14 May 2004 11:20:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16548.7902.186529.386244@cse.unsw.edu.au>
References: <20040513082245.GM22052@suse.de>
	<16547.16795.844328.645694@cse.unsw.edu.au>
	<20040513104552.GT22052@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BORNc-0003Ws-C3
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 18:20:52 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BORNb-00049M-TN
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 18:20:52 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <okir@suse.de>) (for <bfields@fieldses.org>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 14 May 2004 11:20:38 +1000
To: Olaf Kirch <okir@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from Olaf Kirch on Thursday May 13
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

On Thursday May 13, okir@suse.de wrote:
> 
> I haven't yet figured out exactly what happens, but _something_ calls
> exp_get_by_name for /boot prior to mount's call. This leaves an invalid
> item in the cache, and svc_export_update doesn't fix the flags.

My only guess for what could be calling exp_get_by_name is exp_parent,
which would be called when user-space asked for a file handle
at-or-below the point in question.  But I don't know if or why that is
happening.

Bruce's patch is the right thing to fix the problem, though I would
clear the bit *after* the UPDATE has been completed, just to make sure
no-one see an inconsistent structure.  Thanks Bruce.

> > Also, are you running with the nfsd filesystem mounted on
> > /proc/fs/nfsd (or /proc/fs/nfs) or with it unmounted?
> 
> The nfsd file system is not mounted, but I think this shouldn't 
> make a difference.

It makes a big difference to how exportfs and mountd do their stuff.
They are less pro-active about giving information to the kernel, and
more reactive, only giving it when asked for.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

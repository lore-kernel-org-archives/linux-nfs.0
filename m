From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] DefineSimpleCache macro problem
Date: Thu, 13 May 2004 19:36:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16547.16795.844328.645694@cse.unsw.edu.au>
References: <20040513082245.GM22052@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOCdy-0001SB-Jc
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 02:36:46 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BOCdy-0008Tn-8S
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 02:36:46 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <okir@suse.de>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Thu, 13 May 2004 19:36:39 +1000
To: Olaf Kirch <okir@suse.de>
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
> Hi,
> 
> the 2.6 code has this new cache stuff to create caches for various
> things, which is used for the export table and ip client list.
> 
> I came across a strange problem where a host exported several directories
> to a group of clients, but clients were unable to mount more than one.
> 
> It turned out that the problem was caused by svc_export_lookup, which
> will create bogus entries even if called in lookup-only mode.  This caused
> bogus export entries to be created, which didn't have the VALID flag set.
> 
> Essentially, the macro-defined function in sunrpc/cache.h will always
> create entries in the cache, even if "set == 0". The attached patch
> fixes this, and changes the lookup functions to return NULL in this
> case, rather than a bogus entry.

That would be wrong.  Always returning an entry (possibly non-VALID)
- except on kmalloc failure - is a design feature.
If a non-VALID entry is returned the caller typically initiates an
upcall for the information in that entry (unless one is already
pending), and then the request is deferred until the entry is filled
in. When the cache item is marked VALID, all the deferred requests
attached to it are queued for re-processing.
So we definitely want to return the non-VALID entry.

Can you help understand more about your particular problem?
Why do you think that svc_export_lookup returning a non-VALID entry
causes a problem.
It is only called with "set" == 0 in exp_get_by_name, and
exp_get_by_name will only return it to the caller it is VALID.
So I cannot figure out what the real problem is yet.

Also, are you running with the nfsd filesystem mounted on
/proc/fs/nfsd (or /proc/fs/nfs) or with it unmounted?


NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

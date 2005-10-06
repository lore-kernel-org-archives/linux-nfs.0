From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils 1 of 10  - Removed sync warning on readonly exports
Date: Thu, 6 Oct 2005 15:30:58 +1000
Message-ID: <17220.46738.524366.494475@cse.unsw.edu.au>
References: <433414BD.5080209@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENOLc-0004Ei-EJ
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 22:31:16 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENOLb-0002Ln-Tc
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 22:31:16 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Friday September 23
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

On Friday September 23, SteveD@redhat.com wrote:
> The following 10 patches are a result of bugs that were reported
> to us and have been fixed in various Red Hat releases.
> I'm hopeful that at least some of them will incorporated into
> the SourceForge CVS tree....
> 
> steved.
> 

Thanks Steve (and sorry about the delay).
I've incorporated some of them into SourceForge CVS (oh how I wish it
was something other than CVS !!).

Tree is tagged nfs-utils-1-0-7-post6 after the commit, and -post5
before.

 "[NFS] [PATCH] nfs-utils 1 of 10  - Removed sync warning on readonly exports"
   Included unchanged.

 "[NFS] [PATCH] nfs-utils 2 of 10 - Incorporate some clean up code from Ulrich Drepper"
   I re-wrote this with a separate function 'closeall' which is called
   from various places.  
   The 'signal' changes I left out because there was no explanatory
   text :-)

 "[NFS] [PATCH] nfs-utils 3 of 10 - Make sure check_new_cache() looks in the right place"
   I think the change to check_new_cache is wrong.  It really needs to
   check if /proc/fs/nfs{,d} is mounted, and it doesn't do that any
   more.
   The other change in this patch -removing the warning - is included
   unchanged. 

 "[NFS] [PATCH] nfs-utils 4 of 10 - Replaced a memcopy with explicit assignment"
   Already in the CVS.

 "[NFS] [PATCH] nfs-utils 5 of 10 - make sure the correct hostname is used in the SM_NOTIFY"
   Rather ugly, but then statd is fairly ugly already.  I looks
   believable so I included it unchanged.

 "[NFS] [PATCH] nfs-utils 6 of 10 - Fixed subscripting problem in idmapd"
   Yep, good.

 "[NFS] [PATCH] nfs-utils 7 of 10 - Changed mountd to use stat64()"
   Not included. 
   Can you say more about:

           I wonder if it would be better just to make mountd a 64bit
           application by compiling with -D_FILE_OFFSET_BITS=64?

   I thought that when you compiled with a newer glibc, you
   automagically got 64bit stuff...


 "[NFS] [PATCH] nfs-utils 8 of 10 - added the command line arguments to rpc.nfsd"
   Not included.  Uses functionality specific to redhat kernel.

 "[NFS] [PATCH] nfs-utils 9 of 10 - Fixed some security issues found by SGI"
   The bugzilla entry isn't world-readable, but the patch looks fine
   and is included as-is.

 "[NFS] [PATCH] nfs-utils 9 of 10 - Changed xlog to use LOG_INFO instead of LOG_DEBUG"
   Yep, that's ok too.

If you would like to 
 - comment more on the 'signal' changes in patch 3
 - talk about the underlying problem wrt check_new_cache()
 - help me understand the 64-bit options wrt patch 7
 - re-open the debate on specifying version/protocol option to the
   kernel,

I am all ears.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

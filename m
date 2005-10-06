From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils 1 of 10  - Removed sync warning on readonly
 exports
Date: Thu, 06 Oct 2005 09:45:25 -0400
Message-ID: <43452A75.9030404@RedHat.com>
References: <433414BD.5080209@RedHat.com> <17220.46738.524366.494475@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENW43-0005xu-84
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 06:45:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENW41-00011E-8u
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 06:45:39 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17220.46738.524366.494475@cse.unsw.edu.au>
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

Neil Brown wrote:
> Thanks Steve (and sorry about the delay).
np...

> I've incorporated some of them into SourceForge CVS 
Excellent! The more I can get in your world the less I need
to keep in mine... ;-)

> 
>  "[NFS] [PATCH] nfs-utils 2 of 10 - Incorporate some clean up code from Ulrich Drepper"
>    I re-wrote this with a separate function 'closeall' which is called
>    from various places.  
Cool...

>    The 'signal' changes I left out because there was no explanatory
>    text :-)
yeah, our glibc guys notice the fact we weren't using the newer
signal management API (i.e. setset()) and for some reason
(which I can't remember at the moment) they thought that was bad.
I'll ping them and ask what their reason was...

> 
>  "[NFS] [PATCH] nfs-utils 3 of 10 - Make sure check_new_cache() looks in the right place"
>    I think the change to check_new_cache is wrong.  It really needs to
>    check if /proc/fs/nfs{,d} is mounted, and it doesn't do that any
>    more.
Well why should mountd and exportfs care if /proc/fs/nfs exists?
Maybe I'm missing something, but it appears that all the cache_XXX
routines only need the auth.unix.ip, nfsd.export, and nfsd.fh files
that are in /proc/fs/nfsd. So I thought it made sense that
check_new_cache() should run through a file list (similar to what the
other cache_XXX routines do) making sure those files exist. With the
obvious point being, if those files do exist, the filesystem is mounted.


> 
>  "[NFS] [PATCH] nfs-utils 7 of 10 - Changed mountd to use stat64()"
>    Not included. 
>    Can you say more about:
> 
>            I wonder if it would be better just to make mountd a 64bit
>            application by compiling with -D_FILE_OFFSET_BITS=64?
> 
>    I thought that when you compiled with a newer glibc, you
>    automagically got 64bit stuff...
Even on 32bit machine? I thought you had to explicitly ask the
complier for 64bit offsets...  Anyways, this patch stop
rpc.mountd from failing when a file > 2g was mounted.
(i.e. 'mount server:/export/3gigfile /mnt/3gigfile' would cause
rpc.mountd to fail with with "Value too large for defined data type").

My fix was was to change all the stat() calls to stat64() calls
which fix the problem. But I was wondering if it made more sense
to back out my patch and simply compile with the
-D_FILE_OFFSET_BITS=64 compile flag....


> 
>  "[NFS] [PATCH] nfs-utils 8 of 10 - added the command line arguments to rpc.nfsd"
>    Not included.  Uses functionality specific to redhat kernel.
> 
Right... but the patch is not depended on any particular kernel.
Meaning rpc.nfsd, with this patch, will function correctly
with or without the kernel patch...


>  - re-open the debate on specifying version/protocol option to the
>    kernel,
> 
> I am all ears.
Good... I'll post the latest version asap...

steved.


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

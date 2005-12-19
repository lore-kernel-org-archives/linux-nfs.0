From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.8-rc1
Date: Mon, 19 Dec 2005 12:52:48 +1100
Message-ID: <17318.4720.969963.469187@cse.unsw.edu.au>
References: <17314.22172.913247.595571@cse.unsw.edu.au>
	<1134718387.3699.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EoAD0-0007sF-DX
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 17:53:02 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EoACw-0001WH-To
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 17:53:02 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Friday December 16
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

On Friday December 16, trond.myklebust@fys.uio.no wrote:
> On Fri, 2005-12-16 at 16:54 +1100, Neil Brown wrote:
> > I have just make a RC release for nfs-utils.
> > nfs-utils-1.0.8-rc1 can be found at
> > 
> >   http://sourceforge.net/project/showfiles.php?group_id=14
> > or (soon) at
> >   http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
> > 
> > There have been an assortment of bugfixes and improvements over the 
> > past year, but nothing major.
> > As I haven't done much testing myself, I am making this an -rc release
> > and hoping that other will test it.  I hope to make a real 1.0.8
> > in late January, so if anyone has some patches they have been saving
> > up, or knows of some annoying problems with nfs-utils, speak now.
> > 
> > NeilBrown 16-December-2005
> 
> The NFSv4 bugzilla lists several issues that we might want to try to
> tackle. See
> 
> http://bugzilla.linux-nfs.org/buglist.cgi?query_format=specific&order=relevance+desc&bug_status=__open__&product=nfs-utils&content=

[Grumble...bugzilla...grumble...no visibility on mailinglists
.. grumble..]

So we have:
36    	nor  	P3  	All  	bfields@fieldses.org  	NEW  	  	server scales poorly to large number of exports

  Linear lists are a bit of problem for large numbers of exports.
  Proposed change to use hashtable...
  I have some code that does AVL trees really nicely..  Then you don't
  have to worry about right-sizing the hash table.

39 	nor 	P3 	All 	kwc@citi.umich.edu 	NEW 		Kerberos Issues with Mixed-case hostnames

  Hmmm.. I wonder we should be aborting if krb5_kt_next_entry returns
  an error...

57 	nor 	P3 	All 	bfields@fieldses.org 	NEW 		unable to export to nfs3 krb5 clients without also export...

  Messy.... the submitter want to allow mount/STATFS and maybe GETATTR
  to succeed with only AUTH_UNIX, even though /etc/exports says that
  krb5 is required to access the filesystem.

  As there is no list of authorised hosts available in this context,
  we really need to give filehandles and stats info away to
  anyone. i.e. even accept AUTH_NONE.  But we only need to do this for
  filesystems which require krb5.

  Maybe we need an export option which says "STATFS/GETATTR may be
  performed for anyone" and set that when we export with krb5....

  Hmmm.. more thought needed.  I don't think this will get into 1.0.8.

58 	nor 	P3 	All 	bfields@fieldses.org 	NEW 		unable to require different security flavors for differen...

  Hmmm.. They want a funny blend of IP based and credential base
  authentication.... I guess that makes atleast a little bit of
  sense.   The IP isn't used for authentication so much as to require
  encryption if it is an un-known IP.... I wonder if svcgssd gets the
  IP address and so can fail the negotiation if a foreign IP asked for
  no encryption.

  The bit about having the same format 'exports' file as 'the others',
  while probably a nice goal, is currently awkward.  So that bit won't
  be possible for 1.0.8.

  The idea of connection IP addresses with GSS auth connects with bug
  57 somewhat..

70 	min 	P4 	All 	bfields@fieldses.org 	NEW 		Confusing anonymous mapping

  Yes there is room for confusion.  But changing defaults is always a
  problem.
  Having '-2' for 'nobody' was never a good idea, as the 16/32 bit
  distinction causes problems already.
  This would probably be easy to fix if we only knew what 'fix'
  meant....


75 	nor 	P3 	Oth 	bfields@fieldses.org 	NEW 		pseudofilesystem paths are confusing and v3-incompatible

  That's a fair comment, but the solution isn't obvious.
  The apparently straight forward approach might be:
    If 'fsid=0' isn't given in /etc/exports, then auto-export
      /var/lib/nfs/pseudo-root
    as fsid=0,ro,... and bind-mount all other exported filesystems
    into a suitable place in there.

  However some people like to export filesystems that aren't yet
  mounted (cdroms).  It would be nice if the request to access
  something under the pseudo-root could be trapped by mountd to do the
  bind-mount then...

  I think there is lots of room for crazy ideas here.  We could even
  get nfsd to follow symlink in that pseudo root filesystem, so
  exported names are symlinked in rather than bind-mounted.

   Hmmmm...



I don't think any of these need to be show-stopper for 1.0.8, thought
36 could probably be addressed easily enough..

Thanks for the pointer.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

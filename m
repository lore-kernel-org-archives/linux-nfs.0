From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs-utils 1.0.8-rc1
Date: Fri, 16 Dec 2005 02:33:07 -0500
Message-ID: <1134718387.3699.10.camel@lade.trondhjem.org>
References: <17314.22172.913247.595571@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnA5p-0008RB-Lz
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 23:33:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnA5n-0002kj-2B
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 23:33:29 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17314.22172.913247.595571@cse.unsw.edu.au>
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

On Fri, 2005-12-16 at 16:54 +1100, Neil Brown wrote:
> I have just make a RC release for nfs-utils.
> nfs-utils-1.0.8-rc1 can be found at
> 
>   http://sourceforge.net/project/showfiles.php?group_id=14
> or (soon) at
>   http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
> 
> There have been an assortment of bugfixes and improvements over the 
> past year, but nothing major.
> As I haven't done much testing myself, I am making this an -rc release
> and hoping that other will test it.  I hope to make a real 1.0.8
> in late January, so if anyone has some patches they have been saving
> up, or knows of some annoying problems with nfs-utils, speak now.
> 
> NeilBrown 16-December-2005

The NFSv4 bugzilla lists several issues that we might want to try to
tackle. See

http://bugzilla.linux-nfs.org/buglist.cgi?query_format=specific&order=relevance+desc&bug_status=__open__&product=nfs-utils&content=

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

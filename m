From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: more on silly names
Date: Sat, 04 Sep 2004 20:41:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094344893.13791.68.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
	 <1094338737.13791.15.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0409041813340.17016@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3l6R-0005li-Oa
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 17:41:55 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C3l6O-00089d-Nh
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 17:41:54 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0409041813340.17016@harp.ngdc.noaa.gov>
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

P=E5 lau , 04/09/2004 klokka 20:15, skreiv Ara.T.Howard:
> it's sqlite - not berkeley db - so there is no mmap'ing at all going on
> (confirmed by strace).

In that case, all writes should automatically be committed to stable
storage before close() returns.

> i've been able to reproduce the problem with a single client using the
> database - eg. the client causes a sillyname on one of it's own files via=
 the
> sequence i outlined before.

So note that sillyrename decisions are not based on whether or not
someone has the file open. They are based on whether or not someone
holds a reference to the dentry.
IOW: it suffices that some process happens to stat() the file while the
unlink() is going on.

Just out of curiosity, though: if you create a completely new file using

   "touch blah; rm blah"

does that result in a sillyrename? I'm wondering if someone has been
messing  with the VFS in the kernel you are running.

Which kernel is it BTW?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

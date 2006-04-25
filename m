From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Parallel I/O with NFS
Date: Tue, 25 Apr 2006 10:00:05 -0400
Message-ID: <1145973605.8193.16.camel@lade.trondhjem.org>
References: <D11A31EB48BE1143B78A4C284CD80D4803D0EC99@HOEXMB2.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FYO5a-00013x-33
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 07:00:26 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FYO5Y-0004qh-8m
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 07:00:26 -0700
To: "Mosher, Chuck C." <Chuck.C.Mosher@conocophillips.com>
In-Reply-To: <D11A31EB48BE1143B78A4C284CD80D4803D0EC99@HOEXMB2.conoco.net>
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

On Tue, 2006-04-25 at 08:09 -0500, Mosher, Chuck C. wrote:
> Gents,
> 
> A common pattern in parallel computing is to have a number of tasks
> (from 2-1000) open the same file, and each writes a non-overlapping
> section of the file.  As the write proceeds, "strips" of the file are
> written by each task, with holes in between tasks, until the complete
> file has been written.
> 
> We've been using this pattern for may years. We recently began testing
> Fedora Core 4, and are now seeing "holes" left in these files. Reading
> the archives for the "Data coherency trouble with multiple clients,
> on2.6.14-rc5", it seems to me that I have a similar problem. I've seen
> references to using "O_DIRECT" to solve this problem, but it is not
> clear to me how this would work. Would I have to restructure my code
> to write data on aligned 512 byte blocks ?

O_DIRECT over NFS does not require any special alignment. The only
restriction is that you cannot combine O_DIRECT and O_APPEND (lack of
support for uncached append() is a restriction of the NFS protocol).

> Our current applications are written in Java, and use the
> java.nio.channels package.  I'd like to stay "pure java" if at all
> possible. I can write a native method to access the file descriptor
> for the java channel, but that would be a bit of a hack. Is there a
> way I can open or mount the file to have it revert to the behavior in
> earlier releases ?

Won't java support the O_DIRECT open flag?

Cheers,
  Trond



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

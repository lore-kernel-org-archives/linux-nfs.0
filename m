From: trond.myklebust@fys.uio.no
Subject: Re: Force client page cache invalidation?
Date: Tue, 24 Feb 2004 21:06:48 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1145.130.128.48.179.1077653208.squirrel@webmail.uio.no>
References: <403B9842.9070001@ibl.bm>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AviqL-0003yo-7O
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 12:07:49 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvidA-0002Db-23
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 11:54:12 -0800
To: "ralph gonzalez" <rgonzale@ibl.bm>
In-Reply-To: <403B9842.9070001@ibl.bm>
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

På ty , 24/02/2004 klokka 10:30, skreiv ralph gonzalez:
> We tend to run multiple applications on a single client, which all mmap
(usually readonly) the same file on an nfs-mounted volume.
> If the file changes on the server, then we would like clients to see
these changes upon closing/reopening this file.
>
> On Solaris (which we are moving from), this would work fine. However
Linux 2.4.22-10mdk (nfs utils 1.0.5) seems to be unwilling to reload the
file cache *when another application already has the file mmapped*.

Which is quite sane semantics for mmap().

> Therefore each time the file is editted on the server, we have to force
all applications mapping this file (on the client in question) to close
the file *simultaneously*, and then allow them to reopen the mapping.
>
> *Question*: Instead, is there a way to force the client to reload the
file cache (exclusively for this file)? (So when we subsequently
close/open the file in each application asynchronously, they see the
correct pages.) Maybe there's a simple option or utility I'm missing?

Linux does not support this sort of kludge and is unlikely to do so for
the near future. The VM simply cannot support it.

In any case, the fact is that strict POSIX mmap() semantics assume
exclusive access to the file on the server while it is mapped on a given
client. If you're not providing that, then you are going to be prone to
some nasty races whether or not the cache invalidation works like Solaris
does.

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

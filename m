From: Martin Pool <mbp@sourcefrog.net>
Subject: Re: nfs/mmap/rename file corruption
Date: Thu, 28 Aug 2003 12:14:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030828121410.4ccc4b45.mbp@sourcefrog.net>
References: <20030828110309.0e0eff6f.mbp@sourcefrog.net>
	<shs1xv6ftp9.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sCIp-0005JQ-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 19:14:23 -0700
Received: from sngrel4.hp.com ([192.6.86.110])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sCIo-0007ns-QE
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 19:14:22 -0700
Received: from XAUBRG2.AUS.HP.COM (xaubrg2.aus.hp.com [15.23.69.43])
	by sngrel4.hp.com (Postfix) with SMTP id C0AF0DF
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 10:14:20 +0800 (SST)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs1xv6ftp9.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 27 Aug 2003 21:37:38 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

Thanks for responding so quickly!

> >>>>> " " == Martin Pool <mbp@sourcefrog.net> writes:
> 
>      > - ccache runs distcc with output to a temporary file
>      >  - distcc opens, mmaps, writes to, munmaps, and closes the
>      >  temporary
>      >    file
>      > - distcc exits
>      >  - ccache renames the temporary file to its proper location in
>      >  the
>      >    ccache
>      > - ccache opens the file read only, and reads from it
> 
> Is this a rename from one directory to the other? 

Yes.

> If so, are you using
> the 'no_subtree_check' option on the server? 

No, I was not.  It happens that the filesystem is exported at its
root.

The manpage from Debian's nfs-kernel-server 1:1.0.3-2 says

    In order to perform this check, the  server  must  include  some
    information  about  the location of the file in the "filehandle"
    that is given to the  client.   This  can  cause  problems  with
    accessing  files  that  are renamed while a client has them open
    (though in many simple cases it will still work).

In this case, the file is not still open at the time it is renamed.
It just still has some dirty pages in the client's memory.

When I set this option on the server then the renamed file gets the
same filehandle and things work properly.  I'll suggest to the user
that they should set it.

> Without the latter option enabled, I would indeed expect the
> behaviour that you describe.

It seems a bit unfortunate that we can get corruption unless a special
option is set.  Will it work on non-Linux nfs servers?

Wouldn't it still be possible to get the client to flush data out
before renaming it?  I tried naively calling nfs_flush_file before
renaming but that didn't seem to do it.

-- 
Martin 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

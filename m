From: Chris Caputo <ccaputo@alt.net>
Subject: Re: cache/mmap()/server coherency problems
Date: Tue, 14 Jan 2003 09:08:47 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301140904490.9310-100000@nacho.alt.net>
References: <shsfzrv20h2.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nacho.alt.net ([207.14.113.18])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YUYv-0007i7-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 09:09:17 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsfzrv20h2.fsf@charged.uio.no>
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

On 14 Jan 2003, Trond Myklebust wrote:
> >>>>> " " == Chris Caputo <ccaputo@alt.net> writes:
> 
>      > On 2.4.18 and 2.4.20 I am seeing the following problem:
>      >  1) client A process C opens and mmaps (PROT_READ, MAP_SHARED) a file on
>      >     an NFS server.  It keeps it mapped for the duration of the
>      >     following steps.
> 
>      >  2) client B process D opens, adds data to the end of the same file, and 
>      >     then closes it.
> 
>      > 3) client B process E runs md5sum on the file.
> 
>      >  4) client A process F runs md5sum on the file too.  But the result is 
>      >     different than the result of the md5sum in step 3.
> 
>      > Under kernel 2.2.21 this problem did not happen.
> 
> Of course it did! NFS cache coherency is *NEVER* guaranteed if 2
> clients are accessing the same file simultaneously particularly so for
> mmap(). That goes for all NFS implementations on all OSes...
> 
> Using POSIX file locking can help you for ordinary file acces, but for
> mmap(), even file locking has issues under 2.4.x.

I may not have been clear.  The issue isn't with simultaneous access.  
Step 4 happens chronologically after step 2 has finished writing to the
file.  Even minutes later, the data examined by step 4 will not be correct
as long as the mmap() in step one is still happening.  I don't expect the
mmap() in step one to get the updated data, of course, but I would expect
a process run after data has been added to the file, to see the new data.  
Is that incorrect for me to think?

Thanks,
Chris



-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: exports(5) formatting question
Date: Fri, 17 May 2002 15:41:43 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15588.38935.954430.777509@notabene.cse.unsw.edu.au>
References: <20020516125514.GA3280@ns.e-sa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Alexander Reeder <alexr@e-sa.org>
In-Reply-To: message from Alexander Reeder on Thursday May 16
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Thursday May 16, alexr@e-sa.org wrote:
> There seems to be a problem in the behavior of exports(5) evaluation
> of /etc/exports.
> 
> For example, how would I write an /etc/exports file to export a
> file system to 172.16.x.x read-only, with an exception of read-write
> to 172.16.4.1?
> 
> The following would seemingly be the answer:
> 
> /export 172.16.0.0/16(ro) 172.16.4.1(rw)
> 
> But after server reboot, the client 172.16.4.1 can't write to
> NFS.

That should work.....
What does /var/lib/nfs/rmtab contain at the point of server reboot?

> 
> Sorry but I've not yet looked at it in detail.  On Solaris
> I can write an equivalent request like this:
> 
> share -F nfs -o ro=-172.16.4.1:@172.16.0.0/16 ,rw=172.16.4.1 /export
> 
> On a similar, but different note, it'd be nice to allow the following
> expression:
> 
> /home           172.16.0.0/16(rw)
> /home/jondoe    172.16.0.0/16(ro)
> 
> Solaris displays an error message (parent-directory (/home)
> already shared) and cannot do this;  *BSD's NFS server is
> per-filesystem-basis and allow this only if /home/jondoe is on
> a different filesystem.

Not "*BSD's NFS server" but "The NFS protocol by design".

You cannot reliably do what you want using NFS.  It might be possibly
to hack something together that would work 99% of the time.  But it
would be a hack.
For example, supposing some file under /home/jondoe  was hard-linked
into /home/janedoe.
Should that file be writable or not?

NeilBrown

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

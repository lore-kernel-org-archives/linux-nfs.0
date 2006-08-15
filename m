From: Neil Brown <neilb@suse.de>
Subject: Re: Can we flush directory data when the ctime changes?
Date: Tue, 15 Aug 2006 13:49:00 +1000
Message-ID: <17633.17452.840813.593342@cse.unsw.edu.au>
References: <17624.15554.514216.623190@cse.unsw.edu.au>
	<1155045918.5673.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCpvV-0007zh-4M
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 20:49:13 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCpvT-0003Yw-7c
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 20:49:13 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Tuesday August 8
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday August 8, trond.myklebust@fys.uio.no wrote:
> On Tue, 2006-08-08 at 17:26 +1000, Neil Brown wrote:
> > 
> > The GETATTR call that the client makes to validate the cache reports
> > that the mtime hasn't change, *but the ctime has*.
> 
> Growl! If the directory contents change, then the mtime should too. Page
> 22 of RFC1813:
> 
>         Mtime is the time when the file data was last modified.  Ctime
>         is the time when the attributes of the file were last changed.
> 
> Directory cookies are not file or directory attributes!
> 
> In addition, NFSv3 has the cookie verifier mechanism for the server to
> specifically inform the client that the cookies are invalid.

What would you expect the user experience to be if the server returned 
NFS3ERR_BAD_COOKIE ?
I cannot really tell from the nfs client code, but I would guess that
the only option would be to start again from the beginning of the
directory, and that would lead to duplicate entries being returned,
which is exactly the problem are seeing (though the server doesn't
return BAD_COOKIE, it just starts again from the beginning).

> 
> IOW: this really needs to be fixed on the _server_. I'm not happy taking
> new patches that may cause the client GETATTR calls to skyrocket again.
> 

I certainly have a lot of sympathy for this position.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

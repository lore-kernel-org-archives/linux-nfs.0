From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 002 of 2] Avoid flush-when-locking when
	interclient	consistency not needed.
Date: Sat, 14 Apr 2007 18:21:05 -0400
Message-ID: <1176589265.6089.20.camel@heimdal.trondhjem.org>
References: <20070306163710.8128.patches@notabene> <1070306054029.8360@suse.de>
	<1173192029.6393.52.camel@heimdal.trondhjem.org>
	<17903.17597.832563.922428@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcqcM-0005OB-HG
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 15:21:14 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1967vGoCpfkqsm2lnpXGJBWLLcOUmVl6vM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HcqcO-0007Le-Az
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 15:21:17 -0700
In-Reply-To: <17903.17597.832563.922428@notabene.brown>
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

On Thu, 2007-03-08 at 10:03 +1100, Neil Brown wrote:
> > 
> > You can argue for or against the need to invalidate caches when the user
> > has specified "nolock" (it might be nice to add a Solaris-style "llock"
> > alias to this one day, btw: nolock == local locking != no locking at
> > all). We used to do this in early 2.4.x kernels, but that was changed.
> > The reason is that locking is the only way of ensuring that the NFS
> > cache is in sync with the server, and the "nolock" exception was
> > breaking this.
> 
> Yes, the name "nolock" does seem to have been unfortunate.  We had one
> customer wondering why it wasn't producing an 'ENOLCK' error status.
> We could create an alias.  "nonlm"?

I'd prefer "llock", simply because that mirrors the same option on
Solaris.

> If you have chosen nocto,nolock, I cannot see any justification in
> expecting any way of ensuring  the NFS cache is in sync with the
> server except at unmount.
> 
> However if you don't like it, that's fine.  It was just a "this might
> be useful, what do you think" rather than "this is important".  The
> other patch of the two was the real bugfix.  Did that pass muster?
> 
> But I worry about adding an 'llock' option that was different from
> 'nolock'.  How would you explain the difference in a way that didn't
> confuse people?

Are we sure that 'llock' differs from 'nolock'? If Chuck is right, then
we could simply make 'llock' set both the 'nolock' 'nocto' flags, and
just document that. I'm not sure that he is, though. According to the
manpage, Solaris documents

        nocto
        
                No close-to-open consistency.
        
        llock
        
                Local locking being used (no lock manager).
        

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

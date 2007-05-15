From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: What's up with those fractional-second mtimes?
Date: Tue, 15 May 2007 13:50:55 -0400
Message-ID: <1179251455.6464.48.camel@heimdal.trondhjem.org>
References: <loom.20070515T045905-915@post.gmane.org>
	<1179239524.6464.26.camel@heimdal.trondhjem.org>
	<loom.20070515T184657-859@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Wuertele <dave-gmane@bfnet.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho1As-000305-FF
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 10:51:02 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1813nMpiLxOqhv2qMjP7E3GzquHyXaBySk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ho1As-0007Lq-3u
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 10:51:05 -0700
In-Reply-To: <loom.20070515T184657-859@post.gmane.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-05-15 at 16:49 +0000, David Wuertele wrote:
> Dave> Can I disable fractional timestamps?  Can I enable proper
> Dave> processing of them?
> 
> Trond> Sounds like a bug in 'cp'. Could you try using 'strace' to sniff if they
> Trond> are really using the 'utimes()' call (rather than the 'utime()' call,
> Trond> which only has a 1 second resolution) then sniff what they are sending
> Trond> as arguments?
> 
> It is not just cp, it is gzip and several other commands (I doubt I could find
> them all) which use utime() instead of utimes().
> 
> Since I don't have control over the tools available on the target, I would like
> to just disable the fractional part of the timestamps altoghether, so that
> utime() returns the same as utimes().
> 
> Is that possible?

No. The you would have to do that on the server, not the client.
Basically you'd have to have a mount option to the XFS/JFS/...
filesystem that limits its time resolution. I'm not aware of any such
mount options at this time.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

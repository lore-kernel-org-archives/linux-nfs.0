From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.21 strange optimization in svcauth_unix.c
Date: Sat, 28 Apr 2007 12:47:37 +0200
Message-ID: <20070428104737.GA3827@janus>
References: <20070427171941.GA27920@janus>
	<17971.4989.320259.441338@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhkSq-0005uL-5c
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 03:47:40 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhkSr-0001tK-HR
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 03:47:42 -0700
In-Reply-To: <17971.4989.320259.441338@notabene.brown>
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

On Sat, Apr 28, 2007 at 07:27:25PM +1000, Neil Brown wrote:
> On Friday April 27, frankvm@frankvm.com wrote:
> > While reading the 2.6.21 version of net/sunrpc/svcauth_unix.c it looks
> > to me that it tries to cache the AUTH_UNIX/AUTH_SYS group list on uid
> > basis and thus deliberately ignore the group ids supplied by the NFS
> > client.
> 
> It is configurable by a switch to mountd, and defaults to 'off'.
> 
> When a request arrives, the kernel tries to ask mountd to map the uid
> to a list of gids.  If mountd says "no", the kernel uses whatever was
> in the RPC request.  If mountd says "yes", the kernel uses the group
> list that mountd provided.  mountd can provide a full list of gids,
> not just the first 16.
> 
> So it is really an alternate to hacking the NFS client.  If you have a
> new kernel and new nfs-utils and run mountd with "-g", you don't need
> your changes to the NFS client.

Thanks for the explanation. It probably wouldn't work in my case
because the secondary group list is set by a setuid root wrapper
around /bin/sh depending on the project one wants to work on. This
allows delegating access control to people without having to
hand out root passwords (it's more complicated but basically this
describes it).

When mountd can do a callout to a program supplying both uid and gid
to obtain the secondary group list then it could be a replacement
for the client side patch for me. It will never be a replacement
for non-linux NFS servers though. Maybe I'll replace the client
side patch by a (smaller) server side patch if that one is easier
to maintain.

I have given up all hope long time ago to get my client side
patch merged.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

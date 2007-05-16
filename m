From: Ian Kent <raven@themaw.net>
Subject: Re: burst mount of NFS over tcp
Date: Wed, 16 May 2007 10:32:50 +0800
Message-ID: <1179282770.3662.8.camel@raven.themaw.net>
References: <c355d91b0705150817le4e067eq35802a8d94af82a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Flavio Leitner <flavio.leitner@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho9Jw-0002bZ-2v
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 19:32:58 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ho9Jy-0001Tc-L0
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 19:32:59 -0700
In-Reply-To: <c355d91b0705150817le4e067eq35802a8d94af82a7@mail.gmail.com>
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

On Tue, 2007-05-15 at 12:17 -0300, Flavio Leitner wrote:
> (please, keep myself on CC because I'm not subscribed)
> 
> Hi,
> 
> In the case of several (>500) mounts running at the same time with -o tcp,
> the number of attempts that succeed is about 300-400 because it run out
> of priviledged port (they are busy in TIME_WAIT state).
> 
> The priviledged port range available (~512 ports) for this can't be changed to
> avoid more port conflicts.
> 
> An option could be reuse these ports in TIME_WAIT state openning the socket
> with SO_REUSEADDR socket option, but the socket is a tuple:
> (local addr, local port, remote addr, remote port, proto) and it must be
> different from the previous one. Well, they always are equal when you
> mount the same NFS server, so it can't be.

This has been discussed before.
The SO_REUSEADDR is used on server side listening sockets and, as far as
I can tell, can't be used on the client side.

But I'm open to be educated.

> 
> I think reducing TIME_WAIT state in kernel enabling fast recycle
> affects other tcp
> connections and have some extra undesireble effects.

Exactly. Ideally there would be a socket pooling mechanism under glibc
RPC which would allow for reuse of connected sockets but I can't think
of a way to do this since file handles are per process. And adding
non-standard syscalls is likely to not be well accepted.

Any ideas?

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

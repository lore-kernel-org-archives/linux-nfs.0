From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: burst mount of NFS over tcp
Date: Tue, 15 May 2007 15:23:44 -0400
Message-ID: <1179257024.6464.66.camel@heimdal.trondhjem.org>
References: <c355d91b0705150817le4e067eq35802a8d94af82a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Flavio Leitner <flavio.leitner@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho2co-000476-7I
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 12:23:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+JOaemJRi5tF2XR0FnfBNamTiVO/Wa470=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ho2co-0000RZ-9I
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 12:24:01 -0700
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
> 
> I think reducing TIME_WAIT state in kernel enabling fast recycle
> affects other tcp
> connections and have some extra undesireble effects.
> 
> The solution I'm proposing is to add two new nfs parameters to specify
> a timeout and a number of retries to mount before fails. i.e.
> 
> # mount -o tcp,rsvretry=10,rsvtimeout=5 server:/export /mnt
> 
> This will affect mount.nfs to try bind a reserved port 10 times with a timeout
> of 5 seconds before give up. If not used, the default behavious is unchanged
> (i.e. try only one time and fails).
> 
> The code should looks like:
> +             int bind_retry=0
> ...
> -               if (bindresvport(so, &laddr) < 0) {
> +              while (bindresvport(so, &laddr) < 0) {
> +                       if (errno == EADDRINUSE && --bind_retry > 0) {
> +                               sleep(bind_timeout);
> +                               continue;
> +                       }
> 
> The real scenario could be a huge fstab or a MDA delivering e-mails for 500
> users with home automounted.
> 
> I was able to mount more than 1000 NFS with success in the second scenario
> where normally I only manage to have 200-400.
> 
> What you think?

Why not fix the 'retry' mount option to deal properly with this case? I
can't see why running out of reserved ports really needs its own mount
options.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

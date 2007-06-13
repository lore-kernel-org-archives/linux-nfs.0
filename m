From: Flavio Leitner <flavio.leitner@gmail.com>
Subject: Re: burst mount of NFS over tcp
Date: Tue, 12 Jun 2007 22:15:32 -0300
Message-ID: <20070613011532.GA7461@gmail.com>
References: <c355d91b0705150817le4e067eq35802a8d94af82a7@mail.gmail.com>
	<1179257024.6464.66.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyHSS-0007NS-Le
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 18:15:37 -0700
Received: from wx-out-0506.google.com ([66.249.82.239])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HyHSU-0003hq-9p
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 18:15:39 -0700
Received: by wx-out-0506.google.com with SMTP id t15so35588wxc
	for <nfs@lists.sourceforge.net>; Tue, 12 Jun 2007 18:15:37 -0700 (PDT)
In-Reply-To: <1179257024.6464.66.camel@heimdal.trondhjem.org>
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


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline


Resending it with updated patch (based on git)

On 5/15/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2007-05-15 at 12:17 -0300, Flavio Leitner wrote:
> > (please, keep myself on CC because I'm not subscribed)
> >
> > Hi,
> >
> > In the case of several (>500) mounts running at the same time with -o tcp,
> > the number of attempts that succeed is about 300-400 because it run out
> > of priviledged port (they are busy in TIME_WAIT state).
> >
> > The priviledged port range available (~512 ports) for this can't be changed to
> > avoid more port conflicts.
> >
> > An option could be reuse these ports in TIME_WAIT state openning the socket
> > with SO_REUSEADDR socket option, but the socket is a tuple:
> > (local addr, local port, remote addr, remote port, proto) and it must be
> > different from the previous one. Well, they always are equal when you
> > mount the same NFS server, so it can't be.
> >
> > I think reducing TIME_WAIT state in kernel enabling fast recycle
> > affects other tcp
> > connections and have some extra undesireble effects.
> >
> > The solution I'm proposing is to add two new nfs parameters to specify
> > a timeout and a number of retries to mount before fails. i.e.
> >
> > # mount -o tcp,rsvretry=10,rsvtimeout=5 server:/export /mnt
> >
> > This will affect mount.nfs to try bind a reserved port 10 times with a timeout
> > of 5 seconds before give up. If not used, the default behavious is unchanged
> > (i.e. try only one time and fails).
> >
> > The code should looks like:
> > +             int bind_retry=0
> > ...
> > -               if (bindresvport(so, &laddr) < 0) {
> > +              while (bindresvport(so, &laddr) < 0) {
> > +                       if (errno == EADDRINUSE && --bind_retry > 0) {
> > +                               sleep(bind_timeout);
> > +                               continue;
> > +                       }
> >
> > The real scenario could be a huge fstab or a MDA delivering e-mails for 500
> > users with home automounted.
> >
> > I was able to mount more than 1000 NFS with success in the second scenario
> > where normally I only manage to have 200-400.
> >
> > What you think?
>
> Why not fix the 'retry' mount option to deal properly with this case? I
> can't see why running out of reserved ports really needs its own mount
> options.

Sure, you are right. What about the attached one?

Thanks!

-- 
Flavio Leitner

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfs-utils-bindrsvp-retry.patch"

[PATCH] Fix retry= to handle lack of reserved port situation

In the case of several (>500) mounts running at the same time
with -o tcp, the number of attempts that succeed is about 300-500
because it run out of priviledged port (they are busy in TIME_WAIT
state).

Signed-off-by: Flavio Leitner <flavio.leitner@gmail.com>
---
 support/nfs/conn.c     |    6 ++++++
 utils/mount/nfsmount.c |   10 +++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/support/nfs/conn.c b/support/nfs/conn.c
index 29dbb82..315d766 100644
--- a/support/nfs/conn.c
+++ b/support/nfs/conn.c
@@ -200,6 +200,12 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_se
 	/* contact the mount daemon via TCP */
 	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
 	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE, FALSE);
+	if (*msock == RPC_ANYSOCK &&
+		rpc_createerr.cf_error.re_errno == EADDRINUSE) {
+		/* Bubble up the error to see how it should be handled. */
+		rpc_createerr.cf_stat = RPC_TIMEDOUT;
+		return NULL;
+	}
 
 	switch (mnt_pmap->pm_prot) {
 	case IPPROTO_UDP:
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 815064a..a2ae520 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -1178,9 +1178,13 @@ #endif
 			perror(_("nfs socket"));
 			goto fail;
 		}
-		if (bindresvport(fsock, 0) < 0) {
-			perror(_("nfs bindresvport"));
-			goto fail;
+		while (bindresvport(fsock, 0) < 0) {
+			t = time(NULL);
+			if (t > timeout || errno != EADDRINUSE) {
+				perror(_("nfs bindresvport"));
+				goto fail;
+			}
+			sleep(10);
 		}
 	}
 
-- 
1.4.1


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--CE+1k2dSO48ffgeK--

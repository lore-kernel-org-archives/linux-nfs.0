From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Fri, 07 Jul 2006 07:13:28 -0400
Message-ID: <44AE41D8.5040302@RedHat.com>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020701060709040304090203"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyoMq-0003Bq-OY
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 04:19:28 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1FyoFf-00049u-S1
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 04:12:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyoFe-0000jx-N9
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 04:12:03 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17576.25386.427824.894874@cse.unsw.edu.au>
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

This is a multi-part message in MIME format.
--------------020701060709040304090203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hey Neil,

Neil Brown wrote:
> Hi,
>  I'd like to put out nfs-utils-1.0.9 by the end of the week.
> There is (or will soon be) a -pre1 in
>   http://www.kernel.org/pub/linux/utils/nfs/
> and
>   git://linux-nfs.org/nfs-utils
> 
> Recent changes can been seen at
>    http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=log
>   
> If anyone cares to do some testing that would be great.

Well using the nfs-utils-1.0.9-pre1 tarball from kernel.org
and the recent kernel patch set you posted here is what I found.

Starting and stopping nfsds did not kill neither the
TCP or UDP connections. There were two problems with this.
One, rpc.nfsd was incorrectly increasing nfsd_serv->sv_nrthreads
in nfsd_svc() by calling nfsd_create_serv(); (Note: another side effect
of this problem was only 7 nfsd process were start instead of 8)
So the solution I've come up with is to only  have nfsd_create_serv()
called when it needs to... basically:
     if (nfsd_serv == NULL) {
         error = nfsd_create_serv();
         if (error)
             goto out;
     }

The second problem was an oops that occurred when the sv_nrthreads was
incremented correctly... and Neil your going to love this one... ;-)

In svc_delete_socket(), sock_release() was being called with a
socket that was already closed... The socket was closed by the
previous sockfd_put() when svsk->sk_sock->file != NULL... So
the code changed from
     if (svsk->sk_sock->file)
         sockfd_put(svsk->sk_sock);
     sock_release(svsk->sk_sock);
to
     if (svsk->sk_sock->file)
         sockfd_put(svsk->sk_sock);
     else
         sock_release(svsk->sk_sock);

The reason Neil is going to love this is I asked him to
make this change because in my previous testing, the only
way I could get the connections to come down was to
always call sock_release() even after the fput() of the
file pointer... So it appears in Neil's rewrite, fput()
is actually doing the release which is how it should work...

Once I got the connections to come up and down as expected, I
noticed I could not turn off any versions...

In the patches I sent Neil, I had to reverse the order of when
nfssvc_setfds() and nfssvc_versbits() were called in rpc.nfsd.
But in Neil's patch it appears nfssvc_versbits() is expect
to be called before nfssvc_setfds(). After I switching the
order of those calls... things started to work as expected..

That patches are attached....

steved.


--------------020701060709040304090203
Content-Type: text/x-patch;
 name="kernel-2.6.17-nfsd109.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-2.6.17-nfsd109.patch"

Don't let rpc.nfsd incorrectly increase the nfsd_serv->sv_nrthreads
and stop sockets from being released twice by only calling sock_release()
on socket that don't have file pointer associated with them.


Signed-off-by: Steve Dickson <steved@redhat.com>
-------------------------

--- linux-2.6.17.i686/fs/nfsd/nfssvc.c.orig	2006-07-06 17:47:22.000000000 -0400
+++ linux-2.6.17.i686/fs/nfsd/nfssvc.c	2006-07-07 06:15:21.000000000 -0400
@@ -265,9 +265,11 @@ nfsd_svc(unsigned short port, int nrserv
 
 	nfsd_reset_versions();
 
-	error = nfsd_create_serv();
-	if (error)
-		goto out;
+	if (nfsd_serv == NULL) {
+		error = nfsd_create_serv();
+		if (error)
+			goto out;
+	}
 	error = nfsd_init_socks(port);
 	if (error)
 		goto failure;
--- linux-2.6.17.i686/net/sunrpc/svcsock.c.orig	2006-07-06 17:47:22.000000000 -0400
+++ linux-2.6.17.i686/net/sunrpc/svcsock.c	2006-07-07 05:41:04.000000000 -0400
@@ -1525,7 +1525,8 @@ svc_delete_socket(struct svc_sock *svsk)
 		spin_unlock_bh(&serv->sv_lock);
 		if (svsk->sk_sock->file)
 			sockfd_put(svsk->sk_sock);
-		sock_release(svsk->sk_sock);
+		else
+			sock_release(svsk->sk_sock);
 		kfree(svsk);
 	} else {
 		spin_unlock_bh(&serv->sv_lock);

--------------020701060709040304090203
Content-Type: text/x-patch;
 name="nfs-utils-1.0.9-pre1-vers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.9-pre1-vers.patch"

nfssvc_versbits() has to be called before nfssvc_setfds()
for the version processing to work correctly

Signed-off-by: Steve Dickson <steved@redhat.com>
-------------------------

--- nfs-utils-1.0.9-pre1/support/nfs/nfssvc.c.orig	2006-07-02 20:02:03.000000000 -0400
+++ nfs-utils-1.0.9-pre1/support/nfs/nfssvc.c	2006-07-07 06:10:01.000000000 -0400
@@ -135,10 +135,10 @@ nfssvc(int port, int nrservs, unsigned i
 	struct nfsctl_arg	arg;
 	int fd;
 
-	nfssvc_setfds(port, protobits, haddr);
-
 	nfssvc_versbits(versbits);
 
+	nfssvc_setfds(port, protobits, haddr);
+
 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
 	if (fd < 0)
 		fd = open("/proc/fs/nfs/threads", O_WRONLY);

--------------020701060709040304090203
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------020701060709040304090203
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020701060709040304090203--

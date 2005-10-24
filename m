From: James Yarbrough <jmy@sgi.com>
Subject: Re: [NFS][PATCH] Fix to start nfs services through rsh
Date: Mon, 24 Oct 2005 16:17:32 -0700
Message-ID: <435D6B8C.983D0FA0@sgi.com>
References: <1130179778.4887.33.camel@ibm-rf40cz9kb83.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUBZW-0008BL-MP
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 16:17:42 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EUBZU-0003sl-3t
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 16:17:42 -0700
To: Usha Ketineni <ketineni@us.ibm.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I think you might be able to accomplish the same thing by doing the
following:

	rsh hostname "/sbin/service nfs start < /dev/null"

I haven't tried this to do what you want, but I've used this trick
for other things that want to use getsockname on file descriptor 0.

Usha Ketineni wrote:
> 
> When issuing "rsh hostname /sbin/service nfs start"
> rsh gives the error message "Starting NFS mountd: svc_tcp.c - cannot
> getsockname or listen: Invalid argument [FAILED]"
> 
> When mountd is invoked by rshd, file descriptor 0 is a socket, hence
> getsockname in rpc_init() succeeds so, rpc_init() tries to listen on
> that socket in svc_tcp_create(). The socket is a connected socket, but
> this code is assuming the socket came from inetd (or xinetd) and listen
> & accept can be called to establish a connection.
> 
> When mountd is invoked from the command line or sshd, file descriptor 0
> is not a socket.
> 
> Here is a fix for starting the nfs services through rsh which checks
> whether 0 is not a connected socket and if it is, sets socket to
> RPC_ANYSOCK so, svc_tcp_create() will create a new socket.
> 
> This patched code assumes that any udp socket, or a tcp socket that is
> not connected came from inetd and can be passed to svc_udp_create() or
> svc_tcp_create().
> 
> Signed-off-by: Usha Ketineni <uketinen@us.ibm.com>
> 
> --- nfs-utils-1.0.7.orig/support/nfs/rpcmisc.c  2005-10-24 17:19:07.000000000 -0700
> +++ nfs-utils-1.0.7/support/nfs/rpcmisc.c       2005-10-24 18:48:23.000000000 -0700
> @@ -53,10 +53,17 @@ rpc_init(char *name, int prog, int vers,
>         if (getsockname(0, (struct sockaddr *) &saddr, &asize) == 0
>             && saddr.sin_family == AF_INET) {
>                 int ssize = sizeof (int);
> -               _rpcfdtype = 0;
> +               int tmp_rpcfdtype = 0;
>                 if (getsockopt(0, SOL_SOCKET, SO_TYPE,
>                                 (char *)&_rpcfdtype, &ssize) == -1)
>                         xlog(L_FATAL, "getsockopt failed: %s", strerror(errno));
> +               if (_rpcfdtype != SOCK_STREAM || listen(0,5) != -1) {
> +                       _rpcpmstart = 1;
> +                       _rpcfdtype = tmp_rpcfdtype;
> +               } else {
> +                       sock = RPC_ANYSOCK;
> +                       pmap_unset(prog, vers);
> +               }
>                 _rpcpmstart = 1;
>         } else {
>                 pmap_unset(prog, vers);
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.
> Get Certified Today * Register for a JBoss Training Course
> Free Certification Exam for All Training Attendees Through End of 2005
> Visit http://www.jboss.com/services/certification for more information
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
jmy@sgi.com
650 933 3124

Stupid Internet!


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

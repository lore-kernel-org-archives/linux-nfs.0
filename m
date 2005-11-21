From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 21 Nov 2005 18:07:11 -0500
Message-ID: <1132614431.8011.14.camel@lade.trondhjem.org>
References: <4382252E.4000602@google.com>
	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>
	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeKl0-0005Hy-Au
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 15:07:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EeKkx-0004Kg-K7
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 15:07:30 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <4382515C.9020200@google.com>
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

On Mon, 2005-11-21 at 14:59 -0800, Vince Busam wrote:
> Trond Myklebust wrote:
> > On Mon, 2005-11-21 at 13:51 -0800, Vince Busam wrote:
> > 
> >>Trond Myklebust wrote:
> >>
> >>>On Mon, 2005-11-21 at 11:51 -0800, Vince Busam wrote:
> >>>
> >>>http://client.linux-nfs.org/Linux-2.6.x/2.6.15-rc2/linux-2.6.15-06-rpc_pipe_fix_cleanup.dif
> >>>
> >>
> >>That looks good to me.  After testing this fix for a week, I haven't gotten an Oops, but 
> >>the system still locks up.  The only relevant log message is about an upcall timing out.
> >>
> >>Nov 20 00:19:00 dig kernel: RPC: AUTH_GSS upcall timed out.
> >>Nov 20 00:19:00 dig kernel: Please check user daemon is running!
> > 
> > 
> > What kernel is this? There was a patch from Steve that caused this type
> > of behaviour in some 2.6.14 CITI_ALL patches. That patch has since been
> > removed.
> 
> This is 2.6.13.4, with the __rpc_purge_upcall patch, linux-2.6.13-CITI_NFS4_ALL-1.dif, and 
> an ugly patch that I don't remember why I'm using.
> 
> --- linux-2.6.8/net/sunrpc/auth_gss/auth_gss.c  2004-08-13 22:36:57.000000000 -0700
> +++ linux-2.6.8-new/net/sunrpc/auth_gss/auth_gss.c      2004-08-24 14:44:40.887239458 -0700
> @@ -515,6 +515,8 @@
> 
>          clnt = rpci->private;
>          auth = clnt->cl_auth;
> +       if (auth == NULL)
> +               return;
>          gss_auth = container_of(auth, struct gss_auth, rpc_auth);
>          spin_lock(&gss_auth->lock);
>          while (!list_empty(&gss_auth->upcalls)) {

Could you revert that patch, and just add the one from

http://client.linux-nfs.org/Linux-2.6.x/2.6.14/linux-2.6.14-88-rpcsec_gss_fix.dif

That should bring you up to the rpc_pipefs from 2.6.14.

Cheers
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

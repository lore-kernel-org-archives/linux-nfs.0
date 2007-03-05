From: "Matt Proud" <matt.proud.list@gmail.com>
Subject: Re: Possible causes for rpc.mountd consuming 100 percent CPU.
Date: Sun, 4 Mar 2007 22:32:03 -0600
Message-ID: <a6a251db0703042032y742198f9oc0be3de5b59ae57@mail.gmail.com>
References: <a6a251db0703041747l6e539890v7496b616aa8d5cc8@mail.gmail.com>
	<17899.31457.535979.478100@notabene.brown>
	<a6a251db0703041812h7bd3e771q690e30cc789189e0@mail.gmail.com>
	<17899.35209.373099.331797@notabene.brown>
	<17899.36266.588801.465727@notabene.brown>
	<a6a251db0703042017l60a872f7ve93038b169a52968@mail.gmail.com>
	<17899.39862.202935.678726@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HO4rm-0006gD-KN
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 20:32:06 -0800
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HO4rm-0006CK-9d
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 20:32:08 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1198021ugc
	for <nfs@lists.sourceforge.net>; Sun, 04 Mar 2007 20:32:05 -0800 (PST)
In-Reply-To: <17899.39862.202935.678726@notabene.brown>
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

Neil,

I filed a report with Ubuntu:
https://launchpad.net/ubuntu/+source/glibc/+bug/89801.

We'll see who introduces a fix first.

Thank you for your help.

Best,

Matt

On 3/4/07, Neil Brown <neilb@suse.de> wrote:
> On Sunday March 4, matt.proud.list@gmail.com wrote:
> > Yeah, I just pulled the CVS code and discovered that, too.
> >
> > I will contact the Ubuntu and Debian package maintainers about asking
> > them to backport a fix.
> >
> > What would need to be done in nfs-utils to hotfix this, aside from
> > detecting glibc version?
>
> Easiest hot-fix is simply the patch below.
>
> NeilBrown
>
>
> --- a/utils/mountd/svc_run.c
> +++ b/utils/mountd/svc_run.c
> @@ -58,6 +58,24 @@ void cache_set_fds(fd_set *fdset);
>  int cache_process_req(fd_set *readfds);
>
>
> +static void
> +my_svc_getreqset (fd_set *readfds)
> +{
> +  register fd_mask mask;
> +  register fd_mask *maskp;
> +  register int setsize;
> +  register int sock;
> +  register int bit;
> +
> +  setsize = _rpc_dtablesize ();
> +  if (setsize > FD_SETSIZE)
> +    setsize = FD_SETSIZE;
> +  maskp = readfds->fds_bits;
> +  for (sock = 0; sock < setsize; sock += NFDBITS)
> +    for (mask = *maskp++; (bit = ffsl (mask)); mask ^= (1L << (bit - 1)))
> +       svc_getreq_common (sock + bit - 1);
> +}
> +
>  /*
>   * The heart of the server.  A crib from libc for the most part...
>   */
> @@ -87,7 +105,7 @@ my_svc_run(void)
>                 default:
>                         selret -= cache_process_req(&readfds);
>                         if (selret)
> -                               svc_getreqset(&readfds);
> +                               my_svc_getreqset(&readfds);
>                 }
>         }
>  }
>
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

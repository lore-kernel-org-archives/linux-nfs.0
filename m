From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 0/7] svc: Incremental svc patchset cleanup
Date: Wed, 10 Oct 2007 12:24:08 +1000
Message-ID: <20071010022408.GA20690@sgi.com>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfR6u-0003lK-TQ
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:15:44 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IfR6x-0000al-TC
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:15:50 -0700
In-Reply-To: <20071009153539.18846.33780.stgit@dell3.ogc.int>
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

G'day,

Compendium reply.

On Tue, Oct 09, 2007 at 10:35:39AM -0500, Tom Tucker wrote:
> This patchset is a series of independent, incremental patches against
> the previously posted svc transport switch patchset. I believe each
> of these patches can be taken independently. They are presented as a 
> series soley because they reflect what I believe to be the collective 
> consensus of the svc transport switch review.
> 
> The main, non-trivial changes are as follows:
> 
> - Transport class data is no longer copied to each transport instance.
> 
> - A svc_xprt_find service has been added to allow a service to query
>   for transport instances based on class name, address family and port.
> 

> Subject: [RFC,PATCH 1/7] svc: Don't copy xprt_class data into svc_xprt instance

ok

> Subject: [RFC,PATCH 2/7] svc: Rename xpo_release to xpo_release_rqst

ok

> Subject: [RFC,PATCH 3/7] svc: Move setting of XPT_LISTENER bit to svc_tcp_init

ok

> Subject: [RFC,PATCH 4/7] svc: Add a sockaddr length argument to the xpo_create function.

ok

> Subject: [RFC,PATCH 5/7] svc: Remove extraneous debug svc_send printk

ok

> Subject: [RFC,PATCH 6/7] svc: Add svc API that queries for a transport instance

> @@ -242,11 +230,11 @@ static int make_socks(struct svc_serv *s
>         int err = 0;
>                                                                                                                                           
>         if (proto == IPPROTO_UDP || nlm_udpport)
> -               if (!find_xprt(serv, "udp"))
> +               if (!svc_find_xprt(serv, "udp", 0, 0))
>                         err = svc_create_xprt(serv, "udp", nlm_udpport,
>                                               SVC_SOCK_DEFAULTS);
>         if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
> -               if (!find_xprt(serv, "tcp"))
> +               if (!svc_find_xprt(serv, "tcp", 0, 0))
>                         err = svc_create_xprt(serv, "tcp", nlm_tcpport,
>                                               SVC_SOCK_DEFAULTS);

You could use AF_UNSPEC as the "wildcard" value for address family.

> +struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
> +                              int af, int port)
> +{
> +       struct svc_xprt *xprt = NULL;
> +       list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {

Why have address family and port?  Do you need them?

Also, if this is a generic, exported API, it should be taking
serv->sv_lock to protect traversal of the sv_permsocks list.

> + * Specifying 0 for the address family or port is a wildcard and will
> + * match any transport with the firt transport with the same class
> + * name active for the service.
> [...]
> +               struct sockaddr_in *sin;
> +               if (strcmp(xprt->xpt_class->xcl_name, xcl_name))
> +                       continue;
> +               sin = (struct sockaddr_in *)&xprt->xpt_local;
> +               if (af && sin->sin_family != af)
> +                       continue;
> +
> +               if (port && (sin->sin_port != port))
> +                       continue;

So what are the intended semantics of svc_find_xprt(,,0,2049) ?
When called like that, it will reach into xprt->xpt_local assuming
it's a sockaddr_in and match the passed port number against whatever
it finds at bytes 2-3.

Perhaps this function could be pruned back to only do what it needs
to do right now, which is match on transport name?


> Subject: [RFC,PATCH 7/7] svc: Place type on same line for new API

ok

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

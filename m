From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 12/33] svc: Add a generic transport svc_create_xprt	function
Date: Fri, 28 Sep 2007 11:15:30 -0500
Message-ID: <1190996130.10604.52.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050159.12677.37758.stgit@dell3.ogc.int>
	<18172.29506.542120.710648@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIWE-0004j3-2U
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:16:46 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbIWH-0004Ix-Th
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:16:51 -0700
In-Reply-To: <18172.29506.542120.710648@notabene.brown>
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

On Fri, 2007-09-28 at 13:21 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index 6151db5..fab0ce3 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -93,3 +93,41 @@ void svc_xprt_init(struct svc_xprt_class
> >  	xpt->xpt_max_payload = xcl->xcl_max_payload;
> >  }
> >  EXPORT_SYMBOL_GPL(svc_xprt_init);
> > +
> > +int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
> > +		    int flags)
> > +{
> > +	int ret = -ENOENT;
> > +	struct list_head *le;
> > +	struct sockaddr_in sin = {
> > +		.sin_family		= AF_INET,
> > + 		.sin_addr.s_addr	= INADDR_ANY,
> > + 		.sin_port		= htons(port),
> > + 	};
> > +	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
> > +	spin_lock(&svc_xprt_class_lock);
> > +	list_for_each(le, &svc_xprt_class_list) {
> > +		struct svc_xprt_class *xcl =
> > +			list_entry(le, struct svc_xprt_class, xcl_list);
> 
> list_for_each_entry is preferred.
> 

Good suggestion,

> > +		if (strcmp(xprt_name, xcl->xcl_name)==0) {
> > +			spin_unlock(&svc_xprt_class_lock);
> > +			if (try_module_get(xcl->xcl_owner)) {
> > +				struct svc_xprt *newxprt;
> > +				ret = 0;
> > +				newxprt = xcl->xcl_ops->xpo_create
> > +					(serv, (struct sockaddr*)&sin, flags);
> > +				if (IS_ERR(newxprt)) {
> > +					module_put(xcl->xcl_owner);
> > +					ret = PTR_ERR(newxprt);
> > +				}
> > +				goto out;
> > +			}
> > +		}
> > +	}
> > +	spin_unlock(&svc_xprt_class_lock);
> 
> if try_module_get fails, you spin_unlock twice.  the "goto out;"
> needs to be moved down one line.
> 

Yikes, bug. Good catch,

> And I'm confused as to why xpo_create returns a pointer which you
> never use.  xpo_accept does the same thing:  a pointer is returned,
> but only the success status is used.  Why not just return
> 0-or-negative-error ??
> 

It will be used later when we centralize the create logic.

> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

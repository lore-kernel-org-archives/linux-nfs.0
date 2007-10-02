From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 29/35] svc: Move common create logic to common code
Date: Tue, 02 Oct 2007 11:51:43 -0500
Message-ID: <1191343903.1565.37.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192834.3250.88964.stgit@dell3.ogc.int>
	<BB17F85E-446E-4DBA-BD0D-8463FC605294@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IckzS-0006sS-IC
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:52:58 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IckzW-0006TC-7F
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:53:03 -0700
In-Reply-To: <BB17F85E-446E-4DBA-BD0D-8463FC605294@oracle.com>
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

On Tue, 2007-10-02 at 12:42 -0400, Chuck Lever wrote:
> On Oct 1, 2007, at 3:28 PM, Tom Tucker wrote:
> >
[...snip...]

> > @@ -1832,6 +1826,12 @@ int svc_addsock(struct svc_serv *serv,
> >  			svc_xprt_received(&svsk->sk_xprt);
> >  			err = 0;
> >  		}
> > +		if (so->sk->sk_protocol == IPPROTO_TCP)
> > +			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
> 
> One might wish that, even though this is in socket-transport-specific  
> code, you didn't have to check the underlying socket's protocol  
> setting here, but that this could be done in a TCP-specific function  
> such as svc_tcp_init.

I'll move it to svc_tcp_init and look at sk_state. Thanks,
Tom
> 
> > +		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
> > +		spin_lock_bh(&serv->sv_lock);
> > +		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
> > +		spin_unlock_bh(&serv->sv_lock);
> >  	}
> >  	if (err) {
> >  		sockfd_put(so);
> 
> Chuck Lever
> chuck.lever@oracle.com
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

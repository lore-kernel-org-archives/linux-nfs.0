From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 13/35] svc: Change services to use new svc_create_xprt service
Date: Thu, 4 Oct 2007 12:35:32 +1000
Message-ID: <20071004023531.GV21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192758.3250.2651.stgit@dell3.ogc.int>
	<608B3480-525A-43C6-945C-3482CDE823FC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdGTn-0007IR-Kb
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 19:30:24 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/WQA27JWT+rE0sAcQghwIYMH2Tcg4pwsw=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdGTs-00087y-Kc
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 19:30:28 -0700
In-Reply-To: <608B3480-525A-43C6-945C-3482CDE823FC@oracle.com>
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

On Tue, Oct 02, 2007 at 11:44:50AM -0400, Chuck Lever wrote:
> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> >
> >-static int find_socket(struct svc_serv *serv, int proto)
> >+static int find_xprt(struct svc_serv *serv, char *proto)
> > {
> > 	struct svc_sock *svsk;
> > 	int found = 0;
> > 	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
> >-		if (svsk->sk_sk->sk_protocol == proto) {
> >+		if (strcmp(svsk->sk_xprt.xpt_class->xcl_name, proto) == 0) {
> > 			found = 1;
> > 			break;
> > 		}
> 
> This is scary.  :-)
> 
> First, I think we would be better off making the server transport API  
> stronger by not allowing ULPs to dig around in svc_xprt or the  
> svc_xprt_class structures directly.  Perhaps you could provide a  
> method for obtaining the transport's NETID.

Or a function to do the match:

struct svc_xprt_ops {
    ...
    int (*xpo_netid_supported)(const char *netid);
    ...
};

Or, your could push the find_xprt() function down into svc_xprt.c
where such futzing belongs.

> Second, is there any guarantee that the string name of the underlying  
> protocol is the same as the name of the transport class?  Is there  
> any relationship between the transport name and the NETIDs it supports?

This is already confused: our "tcp" transport supports both TCP/IPv4
and TCP/IPv6, which are two separate netids "tcp4" and "tcp6" in
TLI jargon.

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

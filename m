From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Thu, 11 Oct 2007 15:25:10 +1000
Message-ID: <20071011052510.GD31422@sgi.com>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfqP3-0005gt-J7
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 22:16:11 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IfqP6-0001U3-7G
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 22:16:13 -0700
In-Reply-To: <20071011022356.3501.63859.stgit@dell3.ogc.int>
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

On Wed, Oct 10, 2007 at 09:23:56PM -0500, Tom Tucker wrote:
> This patchset implements cleanup that is primarily driven by Greg Bank's 
> review of the transport switch. A summary follows:
> 
> - Fix the svc_create_xprt to properly allocate the temporary sockaddr storage
>   necessary for IPv6.
>  
> - Fix the svc_find_xprt service to lock the sv_permsocks list
> 
> - Fix the svc_find_xprt service to handle the address family correctly
>   when matching the port number on IPv6 connections.
> 
> Thanks Greg.
> 
> Other changes include:
> 
> - Use the svc_find_xprt service to support adding and removing knfsd transports
>   by writing strings to the /proc/fs/nfs/portlist file.
> 

> Subject: [RFC,PATCH 1/3] svc: Change sockaddr to sockaddr_storage in
> svc_create_xprt

ok

> Subject: [RFC,PATCH 2/3] svc: Fix bugs in svc_find_xprt


ok

> Subject: [RFC,PATCH 3/3] knfsd: Modify write_ports to use
> svc_find_xprt service

ok by me, but Neil makes a good point about designing this interface
carefully.


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

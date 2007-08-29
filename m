From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 15/20] svc: transport file implementation
Date: Wed, 29 Aug 2007 15:37:32 -0500
Message-ID: <1188419852.7502.48.camel@trinity.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162353.15224.58198.stgit@dell3.ogc.int>
	<46D5C5D1.6080501@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUJg-0003pt-UQ
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 13:39:09 -0700
Received: from ms-smtp-04.texas.rr.com ([24.93.47.43])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQUJk-0007vE-44
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 13:39:13 -0700
In-Reply-To: <46D5C5D1.6080501@oracle.com>
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

On Wed, 2007-08-29 at 15:15 -0400, Chuck Lever wrote:
> Tom Tucker wrote:
> > Create a proc/sys/sunrpc/transport file that contains information 
> > about the currently registered transports.
> 
> How is this different than /proc/fs/nfsd/portlist ?  What does 
> user-space do with the transport name and max payload information?

The transport file contains registered transports. The portlist file
contains transports for which a listening endpoint has been created in
knfsd. The idea was that a user-mode program
(e.g. /etc/init.d/nfsserver) would scan /proc/sys/sunrpc/transport and
then write the transport string name and port to
the /proc/fs/nfsd/portlist file. 

So the transport file insulates user-mode configuration code from
changing when new transports are added, and the /proc/fs/nfsd/portlist
file insulates knfsd from changing when new transports are added.

The max payload is purely informational.

Dunno if this is the best way, but it's what I came up with...



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

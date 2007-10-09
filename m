From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Tue, 09 Oct 2007 17:09:09 -0400
Message-ID: <1191964149.7052.4.camel@heimdal.trondhjem.org>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
	<1191963718.3697.2.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfMJJ-0000IP-2g
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 14:08:13 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfMJM-0003sG-QE
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 14:08:18 -0700
In-Reply-To: <1191963718.3697.2.camel@pc.ilinx>
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


On Tue, 2007-10-09 at 17:01 -0400, Brian J. Murrell wrote:
> On Tue, 2007-10-09 at 16:57 -0400, Trond Myklebust wrote:
> > 
> > No. The portmapper is a userland process and has nothing to do
> > with /proc/sys/sunrpc/max_resvport.
> 
> No wonder I couldn't find the linkage.  :-)
> 
> > The latter controls the kernel's sunrpc client port usage _only_.
> 
> Hrm.  So that would mean only kernel space rpc services, like nfsd?

The client processes only. IOW: the nfs client, lockd client and the
posix acl client.

> I guess there is no way to limit the userspace portmapper the way
> max_resvport does for the kernel rpc services then?

Not as far as I know.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

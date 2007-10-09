From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Tue, 09 Oct 2007 16:57:40 -0400
Message-ID: <1191963460.7052.1.camel@heimdal.trondhjem.org>
References: <1191949933.30724.56.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfM8U-0007cz-Jr
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 13:57:02 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfM8X-0000Gg-IK
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 13:57:08 -0700
In-Reply-To: <1191949933.30724.56.camel@pc.ilinx>
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


On Tue, 2007-10-09 at 13:12 -0400, Brian J. Murrell wrote:
> I've been trying to link /proc/sys/sunrpc/max_resvport to the process
> the portmapper uses to allocate ports from but have not found it.  So
> perhaps somebody here can answer what I hope is a simple question.
> 
> Can /proc/sys/sunrpc/max_resvport be used to limit (the upper bound of)
> the port range that the portmapper will allocate for all RPC servcies?
> If I set it to, say, 900, I can be guaranteed that no RPC servers will
> get bound to ports > 900?

No. The portmapper is a userland process and has nothing to do
with /proc/sys/sunrpc/max_resvport.

The latter controls the kernel's sunrpc client port usage _only_.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

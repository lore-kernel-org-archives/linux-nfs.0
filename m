From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Thu, 11 Oct 2007 09:44:56 -0400
Message-ID: <1192110296.8556.6.camel@heimdal.trondhjem.org>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
	<1191963718.3697.2.camel@pc.ilinx>
	<1191964149.7052.4.camel@heimdal.trondhjem.org>
	<1191965208.3697.5.camel@pc.ilinx>
	<1191973408.7418.18.camel@heimdal.trondhjem.org>
	<1192029030.31407.35.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfyLY-0004dQ-JC
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:45:04 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfyLc-0006Vw-Cs
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:45:09 -0700
In-Reply-To: <1192029030.31407.35.camel@pc.ilinx>
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

On Wed, 2007-10-10 at 11:10 -0400, Brian J. Murrell wrote:
> > Not really. portmap doesn't choose the port numbers: the server
> > processes themselves choose that number, and so they are the ones that
> > you need to fix up.
> 
> Hrm?  Really?  I thought the process of registering an RPC server with
> the port mapper involved the port mapper finding an available port for
> it to run on.  I thought that was whole point of the port mapper -- to
> allocate ports out of a "limited" pool of available ports for services
> that wanted to be available -- rather than the more traditional
> "officially assigned port"-from-IANA method of getting a port number.

Nope. The job of the portmapper is only to _publish_ those port numbers
once the server has selected them.
That way an rpc client needs only to know the server IP address, the
port number on which rpc.portmap is running (port number 111), and the
RPC program number (see /etc/rpc) for the service it is trying to use.

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

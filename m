From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Tue, 09 Oct 2007 19:43:28 -0400
Message-ID: <1191973408.7418.18.camel@heimdal.trondhjem.org>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
	<1191963718.3697.2.camel@pc.ilinx>
	<1191964149.7052.4.camel@heimdal.trondhjem.org>
	<1191965208.3697.5.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfOjc-0006qN-Sf
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 16:43:36 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfOjg-0006cE-Fs
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 16:43:38 -0700
In-Reply-To: <1191965208.3697.5.camel@pc.ilinx>
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


On Tue, 2007-10-09 at 17:26 -0400, Brian J. Murrell wrote:
> On Tue, 2007-10-09 at 17:09 -0400, Trond Myklebust wrote:
> > 
> > The client processes only. IOW: the nfs client, lockd client and the
> > posix acl client.
> 
> I'm sure I'm missing something obvious here, but isn't it the server
> that (chooses and) binds to a port?  What effect does a "max port" have
> on a client when it has to bind to the port the server chose/was given?

There are two ports involved in an IP connection: one source port (i.e.
the client) and one destination port (i.e. the server). If bind() is run
on a socket that was set up by the client, it will set the source port
for the connection.

The reason why an RPC client would want to select a particular port
number is that for most *NIX setups, the ports with number < 1024 will
usually require root privileges to bind() to. By requiring that RPC
calls must originate from such a 'privileged port', an NFS server can
therefore make it slightly harder for an unprivileged process on that
machine to spoof NFS requests.
See the 'secure' and 'insecure' export options on 'man 5 exports'.

> > Not as far as I know.
> 
> Pity.

Not really. portmap doesn't choose the port numbers: the server
processes themselves choose that number, and so they are the ones that
you need to fix up.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

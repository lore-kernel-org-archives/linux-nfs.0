From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: udp port sunrpc unreachable
Date: Thu, 2 Feb 2006 10:29:09 -0500
Message-ID: <20060202152909.GC12118@fieldses.org>
References: <drsiub$vok$1@sea.gmane.org> <1138890697.8894.2.camel@lade.trondhjem.org> <20060202151908.GB12118@fieldses.org> <1138893904.8894.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Lantschner <ingo.lists@vum.at>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4gOY-00055y-Hp
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 07:29:14 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4gOY-0004od-60
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 07:29:14 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138893904.8894.11.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Feb 02, 2006 at 10:25:04AM -0500, Trond Myklebust wrote:
> On Thu, 2006-02-02 at 10:19 -0500, J. Bruce Fields wrote:
> > On Thu, Feb 02, 2006 at 09:31:37AM -0500, Trond Myklebust wrote:
> > > Portmap appears only to be listening on the loopback adddress. Are you
> > > perhaps starting it before the external network comes up?
> > 
> > I think that's actually the debian default setting these days; with the
> > debconf verbosity at the default, it should have asked you about this
> > when portmap was installed.  Just edit /etc/default/portmap to comment
> > out the obvious line.
> 
> If true, then that would appear to be a rather ridiculous default. Have
> they put out a rationale for this?

Nope, I'm wrong, the default is the opposite.  So probably someone chose the
more secure-sounding option at install time and then forgot about it....

--b.

Template: portmap/loopback
Type: boolean
Default: false
_Description: Should portmap be bound to the loopback address?
 Portmap by default listens to all IP addresses. However, if you are
 not using RPC services that connect to remote servers (like NFS or NIS)
 you can safely bind it to the loopback IP address 127.0.0.1.
 .
 This will allow RPC local services (like FAM) to work properly while
 preventing remote systems from accessing your RPC services.
 .
 You can change this configuration also by editing the OPTIONS
 line in the /etc/default/portmap file. If you just don't specify
 the -i option it will bind to all interfaces.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

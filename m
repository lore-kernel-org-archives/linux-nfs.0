From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: udp port sunrpc unreachable
Date: Thu, 02 Feb 2006 10:25:04 -0500
Message-ID: <1138893904.8894.11.camel@lade.trondhjem.org>
References: <drsiub$vok$1@sea.gmane.org>
	 <1138890697.8894.2.camel@lade.trondhjem.org>
	 <20060202151908.GB12118@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ingo Lantschner <ingo.lists@vum.at>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4gLX-0004q3-4a
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 07:26:07 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4gLU-0006p3-SF
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 07:26:07 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060202151908.GB12118@fieldses.org>
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

On Thu, 2006-02-02 at 10:19 -0500, J. Bruce Fields wrote:
> On Thu, Feb 02, 2006 at 09:31:37AM -0500, Trond Myklebust wrote:
> > Portmap appears only to be listening on the loopback adddress. Are you
> > perhaps starting it before the external network comes up?
> 
> I think that's actually the debian default setting these days; with the
> debconf verbosity at the default, it should have asked you about this
> when portmap was installed.  Just edit /etc/default/portmap to comment
> out the obvious line.

If true, then that would appear to be a rather ridiculous default. Have
they put out a rationale for this?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

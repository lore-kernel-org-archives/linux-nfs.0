From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: udp port sunrpc unreachable
Date: Thu, 2 Feb 2006 10:19:08 -0500
Message-ID: <20060202151908.GB12118@fieldses.org>
References: <drsiub$vok$1@sea.gmane.org> <1138890697.8894.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Lantschner <ingo.lists@vum.at>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4gEx-0004KR-9x
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 07:19:19 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4gEv-0001vg-If
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 07:19:19 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138890697.8894.2.camel@lade.trondhjem.org>
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

On Thu, Feb 02, 2006 at 09:31:37AM -0500, Trond Myklebust wrote:
> Portmap appears only to be listening on the loopback adddress. Are you
> perhaps starting it before the external network comes up?

I think that's actually the debian default setting these days; with the
debconf verbosity at the default, it should have asked you about this
when portmap was installed.  Just edit /etc/default/portmap to comment
out the obvious line.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

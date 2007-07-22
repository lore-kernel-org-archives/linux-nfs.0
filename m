From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Status of mount.nfs
Date: Sun, 22 Jul 2007 17:58:13 -0400
Message-ID: <1185141493.6577.14.camel@localhost>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ICjRS-0003u5-8n
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 14:58:24 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+lLEzCAkJe6ywpMifuYvi70qkBVzOX5aQ=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ICjRV-0000zV-RO
	for nfs@lists.sourceforge.net; Sun, 22 Jul 2007 14:58:22 -0700
In-Reply-To: <20070722191733.GA31501@uio.no>
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

On Sun, 2007-07-22 at 21:17 +0200, Steinar H. Gunderson wrote:
> On Mon, Jul 16, 2007 at 08:15:19PM +1000, Neil Brown wrote:
> > Hmmm.... That code looks a little odd.  If you say you want udp, it
> > will still probe for tcp first.  That doesn't hurt as UDP and TCP
> > always use the same port: 2049.  But it is still odd.  I wonder if it
> > is needed at all.
> 
> It seems it broke for a more normal situation as well:
> 
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=433881
> 
> Giving the "udp" option helped the user, though, but I don't really see why
> the behavior changed.
> 
> /* Steinar */

The default _had_ to change to TCP because UDP is just too unreliable
for NFS running with large (> 8k) r/w sizes, or on nonhomogeneous
networks (mixed 10/100/1000Gbit), or with fast clients.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

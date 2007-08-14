From: John Goerzen <jgoerzen@complete.org>
Subject: Re: Live performance tools?
Date: Tue, 14 Aug 2007 13:03:39 -0500
Message-ID: <200708141303.39663.jgoerzen@complete.org>
References: <slrnfc1j28.fcc.jgoerzen@katherina.lan.complete.org>
	<46C1E8E8.3060405@ilm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Eli Stair <estair@ilm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IL0k5-0004cV-8M
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 11:03:45 -0700
Received: from gatekeeper.excelhustler.com ([69.44.136.67]
	helo=excelhustler.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IL0k8-0007XK-7d
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 11:03:49 -0700
In-Reply-To: <46C1E8E8.3060405@ilm.com>
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

On Tue August 14 2007 12:39:52 pm Eli Stair wrote:
> Try lighting up an instance of ntop on the network you've got your NFS
> server(s) on.  Either span/mirror the switch ports so it sees all the
> traffic in promisc mode, or turn on sflow forwarding to the box.  As for

I was using iftop, but the traffic was too "spikey" to be able to identify 
long-term trends with it.  I'll take a look at ntop.

> determining what files are being accessed, you can use ethereal to
> capture traffic on the wire and analyze file ops occuring, but it's not
> fun to try and analyze #ops/file... you'd have to filter quite well,

Yes, that's exactly the problem I was fearing.

> You could also start up inotify on the linux NFS server, watching the
> entire directory tree you're exporting via NFS, log the output, and

Oh, EXCELLENT idea.  I don't know why I didn't think of that.  That could be 
very useful indeed.

I'm not familiar with ganglia, cacti, or monami, but will investigate.

Thanks very much for the suggestions.  This will be helpful.

-- John

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

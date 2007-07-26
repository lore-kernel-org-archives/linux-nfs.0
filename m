From: Ian Kent <raven@themaw.net>
Subject: Re: Autofs failed auto umounting NFS shares exported by
 Solaris 10
Date: Thu, 26 Jul 2007 21:38:23 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0707262135460.22065@raven.themaw.net>
References: <46A57CFA.2010507@schrodinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Simon Gao <gao@schrodinger.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE3Xx-0002zl-FY
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 06:38:38 -0700
Received: from out2.smtp.messagingengine.com ([66.111.4.26])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IE3Y0-0004zY-6N
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 06:38:33 -0700
In-Reply-To: <46A57CFA.2010507@schrodinger.com>
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

On Mon, 23 Jul 2007, Simon Gao wrote:

> Hi,
> 
> I am seeing RHEL/CentOS 5.0 machine failed to un-mount NFS share 
> exported by Solaris 10 after time out period:

How about providing a debug log?
See http://people.redhat.com/jmoyer for what we need.
What is the kernel version?

btw, the autofs list is probably a better place for this to be discussed.
It can be found at http://linux.kernel.org/mailman/listinfo/autofs.

Ian

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

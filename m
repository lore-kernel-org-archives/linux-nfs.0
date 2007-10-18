From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd crash
Date: Thu, 18 Oct 2007 10:44:44 -0400
Message-ID: <1192718684.7437.3.camel@heimdal.trondhjem.org>
References: <Pine.LNX.4.62.0710181511090.759@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Allard Hoeve <allard@byte.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiWbY-00008P-QS
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 07:44:08 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IiWbc-0005c2-TR
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 07:44:14 -0700
In-Reply-To: <Pine.LNX.4.62.0710181511090.759@office2.c1.internal>
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


On Thu, 2007-10-18 at 15:18 +0200, Allard Hoeve wrote:
> Hello all,
> 
> We've been experincing strange lockd crashes on one of our file servers 
> lately. The kernel lockd gets stuck in a D state and is unkillable, while 
> other NFS processes continue to work fine. Files are served, we're able to 
> mount/umount etc, but trying to attain a lock results in a (killable with 
> KILL) process on the client.
> 
> We're running 2.6.17.3 currently. I know that's not a very new kernel, but 
> we're stuck at that version for the moment, I'm afraid.
> 
> I've attached a stacktrace that dmesg gave us. It would be great if you 
> can take a look at it.
> 
> Regards,
> 
> Allard Hoeve

Already fixed in mainline. Please see

http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc7/linux-2.6.23-001-fix_lockd_circular_dependency.dif

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Allard Hoeve <allard@byte.nl>
Subject: Re: lockd crash
Date: Thu, 18 Oct 2007 17:09:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0710181707440.6931@office2.c1.internal>
References: <Pine.LNX.4.62.0710181511090.759@office2.c1.internal>
	<1192718684.7437.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiX0A-0003F1-Ha
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 08:09:34 -0700
Received: from gw.c1.byte.nl ([82.94.214.64] helo=smtp.byte.nl)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiX0B-0007ch-Ee
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 08:09:39 -0700
In-Reply-To: <1192718684.7437.3.camel@heimdal.trondhjem.org>
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


Hello Trond, all,

>> We've been experincing strange lockd crashes on one of our file servers
>> lately. The kernel lockd gets stuck in a D state and is unkillable, while
>> other NFS processes continue to work fine. Files are served, we're able to
>> mount/umount etc, but trying to attain a lock results in a (killable with
>> KILL) process on the client.
>
> http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc7/linux-2.6.23-001-fix_lockd_circular_dependency.dif

Thanks for the link.

Is it feasible to backport this to, say 2.6.20?

Otherwise, I'll have to find a way to upgrade to 2.6.23, which is a bit 
too new to my tastes :)

Regards,

Allard Hoeve

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

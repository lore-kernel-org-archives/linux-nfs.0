From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH 1/4] mount.nfs: mount's background daemon
	should	free "mount_point" properly
Date: Wed, 22 Aug 2007 00:19:40 +0200
Message-ID: <20070821221940.GA20987@uio.no>
References: <20070821161902.4373.67197.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INc4e-0003PS-04
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 15:19:44 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INc4g-0006VX-VQ
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 15:19:48 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	(Exim 4.50) id 1INc4a-0007VE-V6
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 00:19:41 +0200
Received: from root by trofast.sesse.net with local (Exim 4.67)
	(envelope-from <sesse@samfundet.no>) id 1INc4a-0005TS-En
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 00:19:40 +0200
In-Reply-To: <20070821161902.4373.67197.stgit@monet.1015granger.net>
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

On Tue, Aug 21, 2007 at 12:19:02PM -0400, Chuck Lever wrote:
>  		 * Parent exits immediately with success.  Make
> -		 * sure not to free "mount_point"
> +		 * sure parent doesn't free "mount_point".

What made this change?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

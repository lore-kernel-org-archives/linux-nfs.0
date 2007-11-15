From: Neil Brown <neilb@suse.de>
Subject: Re: Oops in rpciod when building procmail from an NFS client
Date: Thu, 15 Nov 2007 15:04:57 +1100
Message-ID: <18235.50537.220883.815864@notabene.brown>
References: <83FE585A3944624683D9A3F69BA108EB0224B633@PUN2K3EXCL01.symphonysv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Yogesh Pahilwan" <Yogesh.Pahilwan@symphonysv.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsVyP-0007nj-II
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 20:05:01 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsVyT-0008Kp-Uw
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 20:05:07 -0800
In-Reply-To: message from Yogesh Pahilwan on Wednesday November 14
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

On Wednesday November 14, Yogesh.Pahilwan@symphonysv.com wrote:
> Hi Folks,
> 
>  
> 
> I am getting following oops while building procmail utility from the NFS
> mounted share when build from the NFS client.
> 
> The NFS server oopses in rpciod during the "Benchmarking your system's
> strstr () implementation" step.
> 
>  
> 
> I am using the following configurations for NFS client and server:
> 
> NFS client configuration: kernel version - 2.6.11-1.1369_FC4

This is a very old kernel.  It is very possible that there is a patch
since then, but it is also possible that it was so long ago that
no-one has a clear memory of it and no-one feels like hunting it down
for you.

I recommend upgrading to a more recent kernel - 2.6.20 at least, and
if the problem persists, report again.

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

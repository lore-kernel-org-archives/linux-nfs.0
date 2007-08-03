From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/10] More mount.nfs clean-ups (and repost of
	earlier patches)
Date: Sat, 4 Aug 2007 08:28:40 +1000
Message-ID: <18099.44056.905044.953627@notabene.brown>
References: <20070803171004.3357.27721.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH5db-00016Q-CG
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 15:28:51 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IH5de-00027a-VD
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 15:28:55 -0700
In-Reply-To: message from Chuck Lever on Friday August 3
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

On Friday August 3, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Note: This patch series contains several patches that have already been
> posted to the list.
> 
> The first two patches are reposted (with a few minor clean-ups) from the 23
> patch series from last week.  The third patch fixes a problem with recent
> changes to umount.nfs that introduced a minor firewall incompatibility.
> 
> As well as a handful of minor fixes, this series also includes two important
> fixes:
> 
> 1.  Make "bg" mounts work in the mount.nfs helper, and
> 
> 2.  Allow TCP connect time outs to be tunable for GETPORT, clnt_ping, and
>     mnt_openclnt
> 
> There has been recent discussion on the list about what transport should be
> used for GETPORT calls, but I haven't included any patches in this series
> to change the current behavior.
> 
> As always, constructive review is welcome from all.

Thanks.  With one small change as I mentioned previously, these are
now all in git.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

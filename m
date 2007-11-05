From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH nfs-utils 1/3] probe_port should not try other
 versions in a version was explicitly given.
Date: Mon, 05 Nov 2007 04:55:55 -0500
Message-ID: <472EE8AB.7080203@RedHat.com>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>
	<1193894817-20622-2-git-send-email-neilb@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IoykB-0003Rl-C0
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 01:59:43 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IoykG-0007yv-U5
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 01:59:49 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lA59xmdN020169
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 04:59:48 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lA59xmqc031982
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 04:59:48 -0500
Received: from [10.13.248.25] (vpn-248-25.boston.redhat.com [10.13.248.25])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	lA59xkgK009322
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 04:59:47 -0500
In-Reply-To: <1193894817-20622-2-git-send-email-neilb@suse.de>
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



Neil Brown wrote:
> Currently if probe port is asked to probe for a specific version, and
> that version is not supported, it will probe other versions too.
> This means that if mountd is run with "--no-nfs-version 3",
> It will first probe for NFS version 3, which will succeed (assuming the
> kernel supported NFSv3), then it will check the matching mountd version (3)
> and probe_port on discovering that isn't supported will try other versions,
> find "1" is supported will succeed.
> 
> This leaves up using mount version 1 for an NFSv3 mount, which doesn't work
> and leads to a SIGSEGV
> 
> There is no case where trying other versions is needed the request one is
> not supported, so simply remove that code.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> ---
>  utils/mount/network.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 63d5f5a..2b09457 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -417,10 +417,6 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>  				continue;
>  			p_prot = protos;
>  		}
> -		if (vers == pmap->pm_vers) {
> -			p_vers = versions;
> -			vers = 0;
> -		}
>  		if (vers || !*++p_vers)
>  			break;
>  	}
Committed.

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

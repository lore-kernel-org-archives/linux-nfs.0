From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH nfs-utils 3/3] Fix bug in auto-exporting
	subordinate mounts.
Date: Mon, 05 Nov 2007 04:54:52 -0500
Message-ID: <472EE86C.9080908@RedHat.com>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>
	<1193894817-20622-2-git-send-email-neilb@suse.de>
	<1193894817-20622-3-git-send-email-neilb@suse.de>
	<1193894817-20622-4-git-send-email-neilb@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IoyjF-0003M3-D0
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 01:58:45 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IoyjK-0007kJ-TN
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 01:58:51 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lA59wi49019876
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 04:58:44 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lA59witN030968
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 04:58:44 -0500
Received: from [10.13.248.25] (vpn-248-25.boston.redhat.com [10.13.248.25])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	lA59whM0009212
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 04:58:43 -0500
In-Reply-To: <1193894817-20622-4-git-send-email-neilb@suse.de>
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
> When mountd gets a request to export a mountpoint which is not
> explicitly exported, but is below an export point that is flagged as
> "crossmnt", it passes the wrong path name to the kernel for the
>   "filehandle -> directory"
> mapping.
> This can badly confuse the NFS client, and is certainly wrong.
> 
> So use the correct path names.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> ---
>  utils/mountd/cache.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ce1a5a9..fd317cd 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -508,7 +508,7 @@ void nfsd_fh(FILE *f)
>  	 */
>  	qword_printint(f, 0x7fffffff);
>  	if (found)
> -		qword_print(f, found->e_path);
> +		qword_print(f, found_path);
>  	qword_eol(f);
>   out:
>  	free(found_path);
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

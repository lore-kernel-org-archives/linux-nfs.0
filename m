Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932135AbaFQSHP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2014 14:07:15 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5HI7F7p004349
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 14:07:15 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-52-159.rdu2.redhat.com [10.10.52.159])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s5HI7Emk019559
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 14:07:15 -0400
Message-ID: <53A083D2.30202@RedHat.com>
Date: Tue, 17 Jun 2014 14:07:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsiostat: Document the output columns in the manpage
References: <1402926721-8104-1-git-send-email-steved@redhat.com>
In-Reply-To: <1402926721-8104-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/16/2014 09:52 AM, Steve Dickson wrote:
> From: Jan Chaloupka <jchaloup@redhat.com>
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
> ---
>  tools/nfs-iostat/nfsiostat.man | 55 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 55 insertions(+)
> 
> diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
> index 3ec245d..b477a9a 100644
> --- a/tools/nfs-iostat/nfsiostat.man
> +++ b/tools/nfs-iostat/nfsiostat.man
> @@ -38,6 +38,61 @@ If one or more
>  .I <mount point> 
>  names are specified, statistics for only these mount points will
>  be displayed.  Otherwise, all NFS mount points on the client are listed.
> +.TP
> +The meaning of each column of \fBnfsiostat\fR's output is the following:
> +.RS 8
> +- \fBop/s\fR
> +.RS
> +This is the number of operations per second.
> +.RS
> +.RE
> +.RE
> +.RE
> +.RS 8
> +- \fBrpc bklog\fR
> +.RS
> +This is the length of the backlog queue.
> +.RE
> +.RE
> +.RE
> +.RS 8
> +- \fBkB/s\fR
> +.RS
> +This is the number of kB written/read per second.
> +.RE
> +.RE
> +.RE
> +.RS 8
> +- \fBkB/op\fR
> +.RS
> +This is the number of kB written/read per each operation.
> +.RE
> +.RE
> +.RE
> +.RS 8
> +- \fBretrans\fR
> +.RS
> +This is the number of retransmissions.
> +.RE
> +.RE
> +.RE
> +.RS 8
> +- \fBavg RTT (ms)\fR
> +.RS
> +This is the duration from the time that client's kernel sends the RPC request until the time it receives the reply.
> +.RE
> +.RE
> +.RE
> +.RS 8
> +- \fBavg exe (ms)\fR
> +.RS
> +This is the duration from the time that NFS client does the RPC request to its kernel until the RPC request is completed, this includes the RTT time above.
> +.RE
> +.RE
> +.RE
> +.TP
> +Note that if an interval is used as argument to \fBnfsiostat\fR, then the diffrence from previous interval will be displayed, otherwise the results will be from the time that the share was mounted.
> +
>  .SH OPTIONS
>  .TP
>  .B \-a " or " \-\-attr
> 

From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Fix logging segfaults on amd64
Date: Sat, 03 Nov 2007 08:51:58 -0400
Message-ID: <472C6EEE.4070900@RedHat.com>
References: <20071021110257.GA24016@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IoIXF-0002X1-NF
	for nfs@lists.sourceforge.net; Sat, 03 Nov 2007 05:55:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IoIXK-0007D2-5k
	for nfs@lists.sourceforge.net; Sat, 03 Nov 2007 05:55:39 -0700
In-Reply-To: <20071021110257.GA24016@uio.no>
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



Steinar H. Gunderson wrote:
> Hi,
> 
> It seems an error crept into nfs-utils 1.1.1 just before release, so exportfs
> -r segfaults on amd64 whenever there is a warning. The attached patch, from
> Steve Langasek, fixes the issue (an abuse of va_list).
> 
> Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
> Signed-off-by: Steve Langasek <vorlon@debian.org>
> 
> --- nfs-utils-1.1.1.orig/support/nfs/xlog.c
> +++ nfs-utils-1.1.1/support/nfs/xlog.c
> @@ -133,9 +133,13 @@ xlog_enabled(int fac)
>  void
>  xlog_backend(int kind, const char *fmt, va_list args)
>  {
> +       va_list args2;
> +
>         if (!(kind & (L_ALL)) && !(logging && (kind & logmask)))
>                 return;
> 
> +       va_copy(args2, args);
> +
>         if (log_syslog) {
>                 switch (kind) {
>                 case L_FATAL:
> @@ -172,10 +176,12 @@ xlog_backend(int kind, const char *fmt, 
>                 fprintf(stderr, "%s: ", log_name);
>  #endif
> 
> -               vfprintf(stderr, fmt, args);
> +               vfprintf(stderr, fmt, args2);
How is using args here "an abuse of va_list"? It seem pretty
straightforward to me...

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

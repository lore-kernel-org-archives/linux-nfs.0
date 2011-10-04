Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932703Ab1JDQwn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Oct 2011 12:52:43 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p94Gqg1G027928
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 4 Oct 2011 12:52:43 -0400
Message-ID: <4E8B39DA.1060604@RedHat.com>
Date: Tue, 04 Oct 2011 12:52:42 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] man pages: fixed a few typos in a couple man pages
References: <1317740912-4589-1-git-send-email-steved@redhat.com>
In-Reply-To: <1317740912-4589-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/04/2011 11:08 AM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/exportfs/nfsd.man |    6 +++---
>  utils/nfsd/nfsd.man     |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
Committed....

steved.

> 
> diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
> index 7365a1b..47b73be 100644
> --- a/utils/exportfs/nfsd.man
> +++ b/utils/exportfs/nfsd.man
> @@ -12,7 +12,7 @@ nfsd \- special filesystem for controlling Linux NFS server
>  .SH DESCRIPTION
>  The
>  .B nfsd
> -filesytem is a special filesystem which provides access to the Linux
> +filesystem is a special filesystem which provides access to the Linux
>  NFS server.  The filesystem consists of a single directory which
>  contains a number of files.  These files are actually gateways into
>  the NFS server.  Writing to them can affect the server.  Reading from
> @@ -86,7 +86,7 @@ should be followed by a newline, with white-space separating the
>  fields, and octal quoting of special characters.
>  
>  On writing this, the program will be able to read back a filehandle
> -for that path as exported to the given client.  The filehandles length
> +for that path as exported to the given client.  The filehandle's length
>  will be at most the number of bytes given.
>  
>  The filehandle will be represented in hex with a leading '\ex'.
> @@ -165,7 +165,7 @@ file.  The user-space program might then write
>  .ti +5
>  nfsd 127.0.0.1 1057206953 localhost
>  .br
> -to indicate that 127.0.0.1 should map to localhost, atleast for now.
> +to indicate that 127.0.0.1 should map to localhost, at least for now.
>  
>  If the program uses select(2) or poll(2) to discover if it can read
>  from the
> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
> index d8988d2..1cf9296 100644
> --- a/utils/nfsd/nfsd.man
> +++ b/utils/nfsd/nfsd.man
> @@ -38,7 +38,7 @@ request on all known network addresses.  This may change in future
>  releases of the Linux Kernel.
>  .TP
>  .B \-p " or " \-\-port  port
> -specify a diferent port to listen on for NFS requests. By default,
> +specify a different port to listen on for NFS requests. By default,
>  .B rpc.nfsd
>  will listen on port 2049.
>  .TP

From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Linux NFS-HOWTO - improvement to Troubleshooting permission denied
Date: Mon, 25 Aug 2008 11:41:02 -0400
Message-ID: <76bd70e30808250841v4e73c576qc1e68c85d88bb989@mail.gmail.com>
References: <87skstbl7j.fsf@jondo.cante.net>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "NFS HOWTO author" <smithere@gmail.com>,
	"http://linux-nfs.org" <linux-nfs@vger.kernel.org>,
	chip@users.sourceforge.net, hjl@users.sourceforge.net,
	jbfields@users.sourceforge.net, jweber@users.sourceforge.net,
	marcmerlin@users.sourceforge.net, neilbrown@users.sourceforge.net,
	steved12345@users.sourceforge.net, trondmy@users.sourceforge.net
To: "Jari Aalto" <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:3452 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbYHYPlJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 11:41:09 -0400
Received: by mu-out-0910.google.com with SMTP id g7so242203muf.1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Aug 2008 08:41:02 -0700 (PDT)
In-Reply-To: <87skstbl7j.fsf-S166JWPS1wRq3zrG9Zoazw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jari-

On Mon, Aug 25, 2008 at 3:36 AM, Jari Aalto <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org> wrote:
>
> Thank you for the NFS howto (last modified 2006). Please add further
> diagnostics to section:
>
>        => "I do not have permission to access files on the mounted volume"
>        http://nfs.sourceforge.net/nfs-howto/ar01s07.html#pemission_issues
>
> The error condition "Permission denied" also happens in certain NFS
> (client/server) combinations and the workaround is to add additional
> mount parameter at client:
>
>        sec=sys
>
> Please add this to the "#pemission_issues" (tag the word seems to have a
> small typo).

This is a known bug in nfs-utils 1.1.3 when used with older client
kernels that do not support text-based mounts.

Seems like an esoteric (ie not widespread) problem, but I could easily
be wrong about that.

-- 
Chuck Lever

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:44020 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab1G2Oec convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 10:34:32 -0400
Received: by yia27 with SMTP id 27so2556266yia.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 07:34:31 -0700 (PDT)
In-Reply-To: <4E326103.6020003@cea.fr>
References: <4E326103.6020003@cea.fr>
Date: Fri, 29 Jul 2011 10:33:06 -0400
Message-ID: <CADnza46ZRS1W96m-czgbOPPjqZ+xPr5QU05K2vgdTC5MaSGeAQ@mail.gmail.com>
Subject: Re: pynfs and newpynfs for NFSv4 and NFSv4.1
From: Fred Isaman <iisaman@netapp.com>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At one point, the 4.0 and 4.1 trees were separate.  However, they have
recently been merged, and both now (and forever more will) point to
the same repository.

Fred

On Fri, Jul 29, 2011 at 3:28 AM, DENIEL Philippe <philippe.deniel@cea.fr> wrote:
> Hi,
>
> I had a look at the repositories listed here
> (http://www.citi.umich.edu/projects/nfsv4/pynfs/) for pynfs. The page lists
> two repositories, but when looking at them, even if their names differ, they
> look pretty similar (same logm same commits).
> Are they different ? Can I use a single newpynfs do validate both NFSv4.0
> and NFSv4.1 ?
>
>   Regards
>
>      Philippe
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

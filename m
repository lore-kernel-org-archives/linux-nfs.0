From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: cross-compile nfs-utils
Date: Tue, 17 Jun 2008 13:52:13 -0400
Message-ID: <4d569c330806171052v1fd4bc95o7d85d7a3263c33da@mail.gmail.com>
References: <6043ada4386b12792b4c0d0b64a30c6b@forsaken.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Andreas Westin" <forsaken-kFn/pJTXB1swFerOooGFRg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:62715 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686AbYFQRwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 13:52:14 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5830633wfd.4
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2008 10:52:13 -0700 (PDT)
In-Reply-To: <6043ada4386b12792b4c0d0b64a30c6b-kFn/pJTXB1swFerOooGFRg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
It would be easiest (and quicker to make it into the distribution) if
you could supply a patch that fixes this for the cross-compile case.
I, for one, don't do cross-compiling and find it difficult to test
these kind of things.

K.C.

On Tue, Jun 17, 2008 at 8:43 AM, Andreas Westin <forsaken-kFn/pJTXB1swFerOooGFRg@public.gmane.org> wrote:
> Hello,
>
> When you cross-compile nfs-utils 1.1.2 for ARM, locktest and rpcdebug
> fails because they don't use the CFLAGS_FOR_BUILD and
> CPPFLAGS_FOR_BUILD. This becomes a problem when you use flags which
> the host compiler doesn't support such as -mthumb.
>
> /Andreas

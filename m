Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50380 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750827AbdAXWPf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 17:15:35 -0500
Date: Tue, 24 Jan 2017 17:15:33 -0500
From: Bruce Fields <bfields@fieldses.org>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Christoph Hellwig <hch@lst.de>, trondmy@primarydata.com,
        linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: [PATCH v2] nfsd: special case truncates some more
Message-ID: <20170124221533.GG20844@fieldses.org>
References: <d6fd33d2-6323-435c-b085-27a7180c4368@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d6fd33d2-6323-435c-b085-27a7180c4368@email.android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2017 at 11:11:49PM +0100, Mkrtchyan, Tigran wrote:
> <br>
>  	/*
> <br>
>  	 * The size case is special, it changes the file in addition to the
> <br>
> -	 * attributes.
> <br>
> +	 * attributes, and file systems don't expect it to be mixed with
> <br>
> +	 * "random" attribute changes.&nbsp; We thus split out the size change
> <br>
> +	 * into a separate calo for vfs_truncate, and do the rest </p></blockquote></div></div></div><div dir="auto"><br></div><div dir="auto">I guess by **calo** you mean **call**.</div><div dir="auto"><br></div><div dir="auto">Tigran.</div><div dir="auto"><div class="gmail_extra"><div class="gmail_quote"><blockquote class="quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><p dir="ltr">as a

Thanks, fixed.

Could you fix your mailer to do plain text, please?

--b.

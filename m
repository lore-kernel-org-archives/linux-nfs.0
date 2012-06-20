Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44202 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab2FTOyL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2012 10:54:11 -0400
Received: by dady13 with SMTP id y13so9932376dad.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2012 07:54:11 -0700 (PDT)
Date: Wed, 20 Jun 2012 07:54:07 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 4/3] lockd: hard-code init_net in lockd case as well
Message-ID: <20120620145407.GA13594@kroah.com>
References: <1340050049-12880-1-git-send-email-bfields@redhat.com>
 <1340050049-12880-4-git-send-email-bfields@redhat.com>
 <20120620132738.GA30742@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120620132738.GA30742@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 20, 2012 at 09:27:38AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The previous patch missed lockd_down, which has the same problem.
> Symptoms were crashes on unmount or reboot.
> 
> Note this was fixed in a different way upstream.
> 
> Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/lockd/svc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

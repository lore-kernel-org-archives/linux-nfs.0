Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:33136 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab2FTQej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2012 12:34:39 -0400
Received: by dady13 with SMTP id y13so10047385dad.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2012 09:34:38 -0700 (PDT)
Date: Wed, 20 Jun 2012 09:34:27 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 1/3] SUNRPC: new svc_bind() routine introduced
Message-ID: <20120620163427.GA6695@kroah.com>
References: <1340050049-12880-1-git-send-email-bfields@redhat.com>
 <1340050049-12880-2-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1340050049-12880-2-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 18, 2012 at 04:07:27PM -0400, J. Bruce Fields wrote:
> From: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> commit cd96891d48a945ca2011fbeceda73813d6286195 upstream.

Um, no, that's not what this commit id is at all.

Where did you get that from?  I kind of don't trust this series now,
care to fix these up with the correct git commit ids and resend them?

thanks,

greg k-h

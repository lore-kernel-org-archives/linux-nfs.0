Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33839 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751726AbdGBIy5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jul 2017 04:54:57 -0400
Date: Sun, 2 Jul 2017 10:54:57 +0200
From: Greg KH <greg@kroah.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: please cherry pick nfs commit df807fffaabd for stable
Message-ID: <20170702085457.GB20685@kroah.com>
References: <20170701160625.GA1851@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170701160625.GA1851@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 01, 2017 at 12:06:25PM -0400, J. Bruce Fields wrote:
> I have a report of divide error on 4.11.5-200.fc25.x86_64:
> 
> 	https://bugzilla.kernel.org/show_bug.cgi?id=196235
> 
> It looks like
> 
> 	df807fffaabd "NFSv4.x/callback: Create the callback service
> 		through svc_create_pooled"
> 
> should have had a stable cc.
> 
> I believe it's needed on any kernel containing bb6aeba736ba "NFSv4.x:
> Switch to using svc_set_num_threads() to manage the callback threads"
> (which went in to 4.9).

Now applied, thanks.

greg k-h

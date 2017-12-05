Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:40437 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbdLES5W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 13:57:22 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
Date: Tue, 5 Dec 2017 16:57:15 -0200 (-02)
To: Thiago Rafael Becker <thiago.becker@gmail.com>
cc: bfields@fieldses.org, neilb@suse.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3 v3] kernel: Move groups_sort to the caller of
 set_groups.
In-Reply-To: <20171205140512.13349-3-thiago.becker@gmail.com>
Message-ID: <alpine.LFD.2.21.1712051655560.13072@tbecker-rhat>
References: <20171130130457.11429-1-thiago.becker@gmail.com> <20171205140512.13349-1-thiago.becker@gmail.com> <20171205140512.13349-3-thiago.becker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems I missed another one in arch/s390, uploaded an update.

On Tue, 5 Dec 2017, Thiago Rafael Becker wrote:

> The responsibility for calling groups_sort is now on the caller
> of set_groups.

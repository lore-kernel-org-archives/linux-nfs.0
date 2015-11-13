Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36548 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295AbbKMPrd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 10:47:33 -0500
Received: by iofh3 with SMTP id h3so101260148iof.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2015 07:47:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151113092254.GA5047@infradead.org>
References: <20151113092254.GA5047@infradead.org>
Date: Fri, 13 Nov 2015 10:47:32 -0500
Message-ID: <CAN-5tyFQxy_Ge+eN1uRbDqwVDuO2XOmZvX+uUgd0waewHq01HA@mail.gmail.com>
Subject: Re: lock reclaim failed!
From: Olga Kornievskaia <aglo@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 13, 2015 at 4:22 AM, Christoph Hellwig <hch@infradead.org> wrote:
> I see the following running xfstestst on latest Linus' tree against
> as sever from the same tree:
>
> generic/089     [ 2000.358405] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [ 2001.769939] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [ 2001.770732] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [ 2122.608136] NFS: nfs4_reclaim_open_state: Lock reclaim failed!

Going against the NetApp server, we have seen this error logged when
the server returned BAD_STATEID to the IO on the delegated stateid. Is
there such error on the network trace?

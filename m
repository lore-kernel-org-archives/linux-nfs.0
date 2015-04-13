Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36078 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbbDMMXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 08:23:19 -0400
Message-ID: <552BB530.50405@gmail.com>
Date: Mon, 13 Apr 2015 20:23:12 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fscache: put reference of parent's usage and n_children
References: <5527C9A0.6030502@gmail.com> <30571.1428924822@warthog.procyon.org.uk>
In-Reply-To: <30571.1428924822@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/13/2015 7:33 PM, David Howells wrote:
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> If netfs exist, fscache must put the reference of parent's
>> usage and n_children, otherwise, never be decreased.
> 
> Good catch.  Though it might be preferable to only increment the counters if
> the list_add() is done.

Thanks for your comments, that's great.
I will update and resend those two patch.

Thanks,
Kinglong Mee

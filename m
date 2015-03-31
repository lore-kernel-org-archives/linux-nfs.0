Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35728 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbbCaPsN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 11:48:13 -0400
Received: by wgdm6 with SMTP id m6so24087216wgd.2
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 08:48:11 -0700 (PDT)
Message-ID: <551AC1B9.60205@plexistor.com>
Date: Tue, 31 Mar 2015 18:48:09 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>,
        Greg KH <gregkh@linuxfoundation.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, trond.myklebust@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: make debugfs file creation failure non-fatal
References: <1427752698-32431-1-git-send-email-jeff.layton@primarydata.com>	<20150330234753.GG6901@fieldses.org>	<20150331140916.GJ6901@fieldses.org>	<20150331142641.GA9961@kroah.com> <20150331111146.5b71b395@synchrony.poochiereds.net>
In-Reply-To: <20150331111146.5b71b395@synchrony.poochiereds.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/31/2015 06:11 PM, Jeff Layton wrote:
> On Tue, 31 Mar 2015 16:26:41 +0200
> Greg KH <gregkh@linuxfoundation.org> wrote:
> 
<>
> We certainly can update the selinux policy to allow gssproxy to do
> this, but:
> 

Or can we update the selinux policy to allow any user access to
debugfs, since as you said it is always Kernel created ?


Thanks
Boaz


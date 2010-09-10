Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:46027 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036Ab0IJS2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 14:28:17 -0400
Received: by ewy23 with SMTP id 23so1928947ewy.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 11:28:16 -0700 (PDT)
In-Reply-To: <955A7DE8C348B04B8A5F07320E171819F1D8D5756E@EXCMSMBX01.ad.bcm.edu>
References: <955A7DE8C348B04B8A5F07320E171819F1D8D5756E@EXCMSMBX01.ad.bcm.edu>
Date: Fri, 10 Sep 2010 14:28:15 -0400
Message-ID: <AANLkTik7Wm9BUQsSue72232ra7eErwOSdywUAJ6he0nz@mail.gmail.com>
Subject: Re: NFS4 on Ubuntu nobody/nogroup user mapping
From: Kevin Coffman <kwc@citi.umich.edu>
To: "Rao, Mitchell" <mitchelr@bcm.edu>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 10, 2010 at 12:47 PM, Rao, Mitchell <mitchelr@bcm.edu> wrote:
> [...]
>
> Oh and rpc.idmapd is running on the client.
>
> I would be happy provide any information that I may have missed, although I may be
> out of contact on the weekend. Also this is my first time using a public listserv so if
> I have made an faux pas, I apologize and please let me know so that I wont repeat it.
>
> Thanks,
> Mitchell--

Hi,

Is your /etc/idmapd.conf configured correctly on both the client and the server?

What versions of nfs-utils and libnfsidmap are involved?

K.C.

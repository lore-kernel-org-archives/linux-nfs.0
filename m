Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34761 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcBJNeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2016 08:34:07 -0500
Received: by mail-io0-f171.google.com with SMTP id 9so21015403iom.1
        for <linux-nfs@vger.kernel.org>; Wed, 10 Feb 2016 05:34:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1455106042.4536.21.camel@fis.unical.it>
References: <1455106042.4536.21.camel@fis.unical.it>
Date: Wed, 10 Feb 2016 14:34:06 +0100
Message-ID: <CA+res+Si1F5MYys3OeALUwSBih-iPp9HPYRkc31r1KHfYHGz0A@mail.gmail.com>
Subject: Re: Kernel crash in Centos 6.6
From: Jack Wang <jack.wang.usish@gmail.com>
To: fedele.stabile@fis.unical.it
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2016-02-10 13:07 GMT+01:00 Fedele Stabile <fedele.stabile@fis.unical.it>:
> Hello all,
> I have a kernel crash when I mount an NFS volume using RDMA transport.
> On client and server is installed Centos 6.6 kernel 2.6.32
> -504.8.1.el6.x86_64
> I use nfs v4
> The client hangs if I execute
> mount -t nfs -o rdma ib-server:/data /data
> Server and client are connected throw Infiniband network and Qlogic
> adapters.
>
> Can you help me?
> Fedele Stabile
>

Please send out the dmesg at least.

You should try to report bug to distribution, or update to some new
stable kernel.


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

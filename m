Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f50.google.com ([209.85.160.50]:52962 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab3AaEXe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 23:23:34 -0500
Received: by mail-pb0-f50.google.com with SMTP id ro8so1385078pbb.23
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 20:23:33 -0800 (PST)
Message-ID: <5109F187.806@gmail.com>
Date: Thu, 31 Jan 2013 09:52:31 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Cannot see contents of files over NFS share.
References: <5109732C.9080306@gmail.com> <20130130202017.GD14256@fieldses.org>
In-Reply-To: <20130130202017.GD14256@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/31/13 01:50, J. Bruce Fields wrote:
> Actually if you're using a recent distro we recommend not using fsid=0.
> Just export as you normally would for v2/v3, and v4 will work too.
>
> --b.

It's still not working. Same issue

I'm running custom kernel --

uname -r
3.4.2-gentoo-r1

With nfsutils version 1.2.6 (say, I've a nfsv41 USE here....)

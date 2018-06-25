Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752409AbeFYPib (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:38:31 -0400
Received: from smtp.corp.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 90188307D860
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2018 15:38:31 +0000 (UTC)
Subject: Re: [PATCH 0/5] nfs-utils: config value setting
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1529496583.7473.8.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3fc90830-d066-9c12-7b7b-8e4ca7f9e381@RedHat.com>
Date: Mon, 25 Jun 2018 11:38:30 -0400
MIME-Version: 1.0
In-Reply-To: <1529496583.7473.8.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/20/2018 08:09 AM, Justin Mitchell wrote:
> As part of my ongoing efforts to improve storage management integration
> with NFS I offer this support for setting configuration file values.
> 
> This code only updates a single config entry at a time, it attempts to
> preserve the existing structure and style of the comments file, and
> takes every precaution that the replacement file is written before using
> rename(2) to replace the original.
> 
> The cli nfsconf tool is also updated to be the first consumer of this
> functionality.
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
All 5 committed... 

steved.

> 
> 

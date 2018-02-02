Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4523 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750805AbeBBPNi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 10:13:38 -0500
Subject: Re: rpcbind Installation Directory
To: Riley Baird <riley@mailo.com>, linux-nfs@vger.kernel.org
References: <20180127110945.18b6771d4a74e1438d4e0a05@mailo.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <4e1217fe-d6fa-c126-31e3-9706afbfde2e@RedHat.com>
Date: Fri, 2 Feb 2018 10:13:35 -0500
MIME-Version: 1.0
In-Reply-To: <20180127110945.18b6771d4a74e1438d4e0a05@mailo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2018 07:09 PM, Riley Baird wrote:
> Hi,
> 
> I was recently trying to install rpcbind from source, and I noticed
> that the default installation directory was /usr. This surprised me,
> since I always thought that software installed by a user should default
> to being installed in /usr/local.
Yes the default is /usr/bin.

> 
> Is there a reason that rpcbind is installed into /usr? If not, I can
> prepare a patch.
./configure --prefix=/usr/local should work.

steved.

> 
> Yours thankfully,
> 
> Riley Baird
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60064 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751689AbdI1Qds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 12:33:48 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 63C301B9EFD
        for <linux-nfs@vger.kernel.org>; Thu, 28 Sep 2017 16:33:48 +0000 (UTC)
Date: Thu, 28 Sep 2017 17:33:46 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: NFS/VSOCK Discussion
Message-ID: <20170928163346.GA16038@stefanha-x1.localdomain>
References: <d95905e8-ca17-5dce-5f15-93d8f8092208@RedHat.com>
 <948a3c6d-cd3c-189d-34b7-e4f78b1aa226@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <948a3c6d-cd3c-189d-34b7-e4f78b1aa226@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 09:48:36AM -0400, Steve Dickson wrote:
> This discussion will be starting in 15 mins or so.... If interested.

Thanks for arranging this call, it was good to get a little deeper into
the requirement for vsock!

Action item:

 * [Stefan] Send draft AF_VSOCK RFC to Linux NFS and vsock communities

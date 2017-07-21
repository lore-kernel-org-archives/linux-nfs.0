Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751760AbdGUOqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 10:46:34 -0400
Subject: Re: [PATCH 03/11] atomicio: removed a warning
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170719205354.10006-1-steved@redhat.com>
 <20170719205354.10006-4-steved@redhat.com>
 <20170720182403.GA19909@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <2b14781b-e37d-02eb-d10e-37a8fc161470@RedHat.com>
Date: Fri, 21 Jul 2017 10:45:54 -0400
MIME-Version: 1.0
In-Reply-To: <20170720182403.GA19909@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/20/2017 02:24 PM, J. Bruce Fields wrote:
> On Wed, Jul 19, 2017 at 04:53:46PM -0400, Steve Dickson wrote:
>> atomicio.c:43:7: warning: this statement may fall through [-Wimplicit-fallthrough=]
> I think this is wrong.  For example, if we don't have permission to do
> the IO, this causes atomicio() to return 0 instead of -1.
I see your point... Nice catch!

steved.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:39690 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751329AbeFVJnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Jun 2018 05:43:16 -0400
Message-ID: <1529660593.7576.5.camel@redhat.com>
Subject: Re: [PATCH 5/5] nfs-utils: Add config setting to nfsconf cli tool
From: Justin Mitchell <jumitche@redhat.com>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Fri, 22 Jun 2018 10:43:13 +0100
In-Reply-To: <e6d15961-2381-8212-253d-6e970587f862@oracle.com>
References: <1529496583.7473.8.camel@redhat.com>
         <1529496853.7473.13.camel@redhat.com>
         <e6d15961-2381-8212-253d-6e970587f862@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-06-22 at 04:18 +0100, Calum Mackay wrote:
> hi Justin, it's not a part of your patch, but I noticed a tiny typo: see 
> below.
> 
> On 20/06/2018 1:14 pm, Justin Mitchell wrote:
> >   	} else {
> >   		fprintf(stderr, "Mode not yet implimented.\n");
> 
> -> implemented

Well spotted, a quick check with the spell checker spots a few others,
so patch submitted separately.

thanks for pointing it out
-J





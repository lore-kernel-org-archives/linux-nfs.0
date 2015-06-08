Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f51.google.com ([209.85.216.51]:33840 "EHLO
	mail-vn0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbbFHNP3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 09:15:29 -0400
Received: by vnbg7 with SMTP id g7so11328893vnb.1
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jun 2015 06:15:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <557525DD.6070300@oracle.com>
References: <557525DD.6070300@oracle.com>
Date: Mon, 8 Jun 2015 09:15:28 -0400
Message-ID: <CAHQdGtSrgLaTRDBxtUCKrt+90WrJq2YR_VfSi9RC4_7m0k--3w@mail.gmail.com>
Subject: Re: [RFC PATCH V3 0/7] nfsd/sunrpc: prepare nfsd to add workqueue support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 8, 2015 at 1:19 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
> This patchset was originally written by Jeff Layton from adding support for a workqueue-based nfsd. I am helping on stability test and performance analysis. There are some workloads benefit from global threading mode, some workloads benefit from workqueue mode. I am still investigating on how to make workqueue mode better to bid global theading mode. I am splitting the patchset into two parts: one is preparing nfsd to add workqueue mode, one is adding workqueue mode. The test results show that the first part doesn't cause much performance change, the results are within the variation from each run.

As stated in the original emails, Primary Data's internal testing of
these patches showed that there is a significant difference. We had 48
virtual clients running on 7 ESX hypervisors with 10GigE NICs against
a hardware NFSv3 server with a 40GigE NIC. The clients were doing 4k
aio/dio reads+writes in a 70/30 mix.
At the time, we saw a roughly 50% decrease with measured standard
deviations being of the order a few % when comparing the performance
as measured in IOPs between the existing code and the workqueue code.

Testing showed the workqueue performance was relatively improved when
we upped the block size to 256k (with lower IOPs counts). That would
indicate that the workqueues are failing to scale correctly for the
high IOPs (i.e. high thread count) case.

Trond

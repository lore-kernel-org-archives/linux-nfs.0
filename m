Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45030 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752191AbdGLO0K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Jul 2017 10:26:10 -0400
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Felix Janda <felix.janda@posteo.de>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
 <20170703090048.GC22607@stefanha-x1.localdomain>
 <2730896d-f9d6-352d-e829-d672d8735bd3@RedHat.com>
 <20170710181447.GW14195@stefanha-x1.localdomain>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <4e57a6f2-87a2-b601-4727-041f6bffcdff@RedHat.com>
Date: Wed, 12 Jul 2017 10:26:02 -0400
MIME-Version: 1.0
In-Reply-To: <20170710181447.GW14195@stefanha-x1.localdomain>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/10/2017 02:14 PM, Stefan Hajnoczi wrote:
> On Mon, Jul 03, 2017 at 12:51:07PM -0400, Steve Dickson wrote:
>> On 07/03/2017 05:00 AM, Stefan Hajnoczi wrote:
>>> On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
>>>> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
>> Are there other implementations out there that would cause breakage?
>> I'm pretty sure nfs-utils is only used in Linux environments, right?
> 
> Does nfs-utils have a set of minimum distro versions that are supported?
Not that I'm aware of... Now there are certain package versions nfs-utils
is dependent on but not particular distro.

steved.
 
> 
> For example, "the latest nfs-utils release is supported on RHEL 6, SLES
> 11, and Debian 8 jessie".
> 
> If yes, then I could go check that these distros ship AF_VSOCK and
> <linux/vm_sockets.h>.
> 
> Stefan
> 

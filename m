Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35868 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822AbcEaSbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2016 14:31:53 -0400
Subject: Re: Configuring fs_locations on Linux upstream server pseudo fs for
 session trunking
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Andy Adamson <androsadamson@gmail.com>
References: <04273F60-806B-4E12-B097-388C346F2DED@oracle.com>
 <40E6E131-029E-4337-A235-B1DB5CA687AA@netapp.com>
 <20160525184837.GA15210@fieldses.org>
 <9614D777-9C75-4FBB-BD06-4EC366273B49@oracle.com>
 <CAHVgHyVEx1fUP36tHaB-uBMJmC3gqCeQ5PSgaHm9XrAWQqerqw@mail.gmail.com>
 <20160526152253.GC21450@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <e8d92a6e-6a02-03e2-1dca-c733f31e1715@RedHat.com>
Date: Tue, 31 May 2016 14:31:51 -0400
MIME-Version: 1.0
In-Reply-To: <20160526152253.GC21450@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/26/2016 11:22 AM, J. Bruce Fields wrote:
>>>>> Idea 1: extra syntax in /etc/exports
>>>> > >>
>>>> > >> It's not really export-specific information.  I wonder if it'd be better
>>>> > >> to pass it on the rpc.nfsd commandline?
>>>> > >>
>>>> > >>       rpc.nfsd --multipath-set="192.168.0.1,192.168.0.2"
>>>> > >>
>>>> > >> (and then that can be configured in /etc/sysconfig/nfs or whatever)?
>> > 
>> > Is this (the rpc.nfsd command line and /etc/sysconfig/nfs entry) the
>> > preferred way?
>> > Is /etc/sysconfig/nfs read upon reboot?
Again, I think this is just globing new stuff on old stuff... 

I'm just thinking having new commands to manage new technology
better direction. 
  
> Yes.  (Well, the details are distribution-dependent, I think it's up to
> the /usr/lib/systemd/scripts/nfs-utils_env.sh script referenced in
> nfs-utils/systemd/nfs-config.service.)
These new command could have their very own system start up scripts

> 
> The annoying thing about putting it on the rpc.nfsd commandline is that
> it's mountd, not nfsd, that manages the NFSv4 pseudofs, and would be
> responsible for cooking up the fs_locations info.
I agree with this... structurally this just seems wrong.

steved. 



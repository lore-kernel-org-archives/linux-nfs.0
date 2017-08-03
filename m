Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36577 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbdHCXxH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 19:53:07 -0400
Received: by mail-pf0-f176.google.com with SMTP id c28so201421pfe.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 16:53:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87tw1otjf1.fsf@notabene.neil.brown.name>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name>
 <87tw2ox4st.fsf@notabene.neil.brown.name> <20170725100513.GA5073@stefanha-x1.localdomain>
 <87eft2wjfy.fsf@notabene.neil.brown.name> <20170727105835.GF10129@stefanha-x1.localdomain>
 <8760edwk4l.fsf@notabene.neil.brown.name> <20170803152446.GA24890@stefanha-x1.localdomain>
 <87tw1otjf1.fsf@notabene.neil.brown.name>
From: Matt Benjamin <mbenjami@redhat.com>
Date: Thu, 3 Aug 2017 19:53:05 -0400
Message-ID: <CAKOnarmMT2FRF8U84tQDZnm-GMeZrEU2UXZHmNXUeqTHpMYo9w@mail.gmail.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
To: NeilBrown <neilb@suse.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On Thu, Aug 3, 2017 at 5:45 PM, NeilBrown <neilb@suse.com> wrote:
> On Thu, Aug 03 2017, Stefan Hajnoczi wrote:

Since the vsock address family is in the tin since 4.8, this argument
appears to be about, precisely, tying existing pieces together.  The
ceph developers working on openstack manila did find the nfs over
vsock use case compelling.  I appreciate this because it has
encouraged more interest in the cephfs community around using the
standardized NFS protocol for deployment.

Matt

>
> I think we all agree that providing something that "just works" is a
> worth goal.  In only question is about how much new code can be
> justified, and where it should be put.
>
> Given that almost everything you need already exists, it seems best to
> just tie those pieces together.
>
> NeilBrown
>
>
>>
>> The changes required to Linux and nfs-utils are related to the sunrpc
>> transport and configuration.  They do not introduce risks to core NFS or
>> TCP/IP.  I would really like to get patches merged because I currently
>> have to direct interested users to building Linux and nfs-utils from
>> source to try this out.
>>
>> Stefan

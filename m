Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35439 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbcGMMev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2016 08:34:51 -0400
Received: by mail-vk0-f42.google.com with SMTP id w127so4472051vkh.2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 05:34:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <014101d1d6df$e059fd20$a10df760$@mindspring.com>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
 <1467294433-3222-9-git-send-email-agruenba@redhat.com> <1467728537.3800.32.camel@redhat.com>
 <014101d1d6df$e059fd20$a10df760$@mindspring.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 13 Jul 2016 14:34:31 +0200
Message-ID: <CAHc6FU5oeaCxgZPFeNSHDfSjnVKe9km14R4s5RoBhJXPaL7ymQ@mail.gmail.com>
Subject: Re: [PATCH v23 08/22] richacl: Compute maximum file masks from an acl
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Jeff Layton <jlayton@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank,

On Tue, Jul 5, 2016 at 7:08 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>> > + * Note: functions like richacl_allowed_to_who(),
>> > +richacl_group_class_allowed(),
>> > + * and richacl_compute_max_masks() iterate through the entire acl in
>> > +reverse
>> > + * order as an optimization.
>> > + *
>> > + * In the standard algorithm, aces are considered in forward order.
>> > +When a
>> > + * process matches an ace, the permissions in the ace are either
>> > +allowed or
>> > + * denied depending on the ace type.  Once a permission has been
>> > +allowed or
>> > + * denied, it is no longer considered in further aces.
>> > + *
>> > + * By iterating through the acl in reverse order, we can compute the
>> > +same
>> > + * result without having to keep track of which permissions have been
>> > +allowed
>> > + * and denied already.
>> > + */
>> >
>>
>> Clever!
>
> Hmm, but does that result in examining the whole ACL for most access checks, at least for files where most of the accesses are by the owner, or a member of a specific group (with perhaps a ton of special case users added on the end)?

I don't understand -- what does this algorithm have to do with access checks?

Thanks,
Andreas

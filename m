Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33244 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934778AbcIWRnC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Sep 2016 13:43:02 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Jeff Layton" <jlayton@redhat.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: nfsd crash when running xfstests/089
Date: Fri, 23 Sep 2016 13:42:59 -0400
Message-ID: <5BC823A6-3E56-4664-9551-02EF7AF7B135@redhat.com>
In-Reply-To: <20160923164054.GA31447@infradead.org>
References: <20160920163717.GA946@infradead.org>
 <1474561258.9454.8.camel@redhat.com> <20160923164054.GA31447@infradead.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 Sep 2016, at 12:40, Christoph Hellwig wrote:

> On Thu, Sep 22, 2016 at 12:20:58PM -0400, Jeff Layton wrote:
>> I had a go at reproducing this, but no luck. I'm running generic/089 on
>> a KVM guest client and with the server running on a different KVM
>> guest. I'm using vhost-scsi to emulate a disk (thanks to Ben Coddington
>> for the help setting that up, btw...)
>
> FYI, I've just used a single guest with both client and server in it
> to reproduce as well.  In that case I'll have to use blocklayout, though
> as the scsilayout requires separate systems for the reservations.
>
>> In any case, I'll poke at it again if I get time. In the meantime, if
>> you're able to get a vmcore, maybe take a look and see if you can
>> figure out what's actually bad there? How far does it get in chasing
>> the pointer to the cl_lock in release_lock_stateid?
>
> How do I get a vmcore under kvm?

If you are using libvirt, then virsh might work:

virsh dump --memory-only VMname dumpfile

Ben

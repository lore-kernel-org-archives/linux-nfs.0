Return-Path: <BATV+2ec0b7ee621439cf862d+4779+infradead.org+hch@bombadil.srs.infradead.org>
Date: Fri, 23 Sep 2016 09:40:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, Benjamin Coddington <bcodding@redhat.com>
Subject: Re: nfsd crash when running xfstests/089
Message-ID: <20160923164054.GA31447@infradead.org>
References: <20160920163717.GA946@infradead.org>
 <1474561258.9454.8.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1474561258.9454.8.camel@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 22, 2016 at 12:20:58PM -0400, Jeff Layton wrote:
> I had a go at reproducing this, but no luck. I'm running generic/089 on
> a KVM guest client and with the server running on a different KVM
> guest. I'm using vhost-scsi to emulate a disk (thanks to Ben Coddington
> for the help setting that up, btw...)

FYI, I've just used a single guest with both client and server in it
to reproduce as well.  In that case I'll have to use blocklayout, though
as the scsilayout requires separate systems for the reservations.

> In any case, I'll poke at it again if I get time. In the meantime, if
> you're able to get a vmcore, maybe take a look and see if you can
> figure out what's actually bad there? How far does it get in chasing
> the pointer to the cl_lock in release_lock_stateid?

How do I get a vmcore under kvm?

FYI, in the meantime I've also managed to reproduce it without pNFS,
althought it seems to take much longer to trigger.  One interesting
thing is that it seem to only happen when the host system has a heavy
CPU load (e.g. building a kernel).

Also I think I've always only reproduce it as part of a xfstests
./check -nfs -g auto, never by just running the test standalone.

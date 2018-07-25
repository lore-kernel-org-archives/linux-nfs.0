Return-Path: <dhowells@redhat.com>
From: David Howells <dhowells@redhat.com>
In-Reply-To: <9322c4d50a0828c7592beaac2bbca63bc0b12255.camel@hammerspace.com>
References: <9322c4d50a0828c7592beaac2bbca63bc0b12255.camel@hammerspace.com> <20180711122219.20808-1-smayhew@redhat.com> <1F59764C-4E7C-4D15-BE35-490D61F0349F@redhat.com> <20180711162447.GI10135@coeurl.usersys.redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: dhowells@redhat.com, "bcodding@redhat.com" <bcodding@redhat.com>,
    "smayhew@redhat.com" <smayhew@redhat.com>,
    "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
    "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: add minor version to nfs_server_key for fscache
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 25 Jul 2018 11:07:04 +0100
Message-ID: <8844.1532513224@warthog.procyon.org.uk>
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trondmy@hammerspace.com> wrote:

> So what is the use case for having a NFSv4 and NFSv4.1 mount of the
> same filesystem? I agree we shouldn't crash, but I'm lost as to why
> someone would want to do this.

Note that one thing I'm thinking of adding to the mount overhaul is the
ability for the VFS core to either upcall or open a config file to find
default parameters for a new mount.  This would make it easier to configure
network and protocol parameters across automounts.

> IOW: Why isn't the right thing to do here just to remove the bogus
> BUG_ON()?

Because it's not exactly bogus - or, rather, it should now be redundant with
the upper layer (fscache) weeding out collisions between live cookies - but
that will still throw a warning that you're getting a collision, say between
an nfs-4.1 and a nfs-4.2 mount.

The problem is that fscache isn't equipped to deal with handling multiple
users of the same cache object and the cache coherence implications there of.
I'm looking to change the former by changing the data I/O interface to take an
iterator and stop it from tracking netfs pages beyond that, but managing cache
coherence has to be up to the network filesystem.

David

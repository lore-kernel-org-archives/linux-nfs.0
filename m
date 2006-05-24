From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [autofs] Re: [NFS] Re: [RFC] Multiple server selection and
 replicated mount failover
Date: Wed, 24 May 2006 13:58:49 -0400
Message-ID: <x49ac97cnja.fsf@segfault.boston.redhat.com>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	<Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
	<1148488156.5872.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1148488156.5872.42.camel@lade.trondhjem.org> (Trond
 Myklebust's message of "Wed, 24 May 2006 12:29:16 -0400")
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

==> Regarding [autofs] Re: [NFS] Re: [RFC] Multiple server selection and replicated mount failover; Trond Myklebust <trond.myklebust@fys.uio.no> adds:

trond.myklebust> On Wed, 2006-05-24 at 13:05 +0800, Ian Kent wrote:
>> > 4) How does NFS v4 fit into this picture as I believe that some
>> >    of this functionality is included within the protocol.
>> 
>> And this.
>> 
>> NFS v4 appears quite different so should I be considering this for v2 and 
>> v3 only?

trond.myklebust> NFSv4 has full support for migration/replication in the
trond.myklebust> protocol. If a filesystem fails on a given server, then
trond.myklebust> the server itself will tell the client where it can find
trond.myklebust> the replicas. There should be no need to provide that
trond.myklebust> information at mount time.

And what happens when the server disappears?

-Jeff

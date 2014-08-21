Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:50527 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbaHUDsx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 23:48:53 -0400
Received: by mail-vc0-f181.google.com with SMTP id lf12so10015279vcb.26
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 20:48:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140821121544.10e11215@notabene.brown>
References: <20140818061727.1449.89101.stgit@notabene.brown>
	<20140818062254.1449.99502.stgit@notabene.brown>
	<1408581916.4029.15.camel@leira.trondhjem.org>
	<20140821111100.0fc7e3c9@notabene.brown>
	<CAHQdGtTLgD9Xw9T5fKAVK1VYEv+U9m_hKcw2SNvQrYEwnkZauQ@mail.gmail.com>
	<20140821121544.10e11215@notabene.brown>
Date: Wed, 20 Aug 2014 23:48:52 -0400
Message-ID: <CAHQdGtSVdZc89v4biz63ovYYSCKWxbNp0Y_FxO=RsO1=Hn=6wA@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFS: avoid deadlocks with loop-back mounted NFS filesystems.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2014 at 10:15 PM, NeilBrown <neilb@suse.de> wrote:
> On Wed, 20 Aug 2014 21:42:55 -0400 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>
>> On Wed, Aug 20, 2014 at 9:11 PM, NeilBrown <neilb@suse.de> wrote:
>> > On Wed, 20 Aug 2014 20:45:16 -0400 Trond Myklebust
>> > <trond.myklebust@primarydata.com> wrote:
>> >
>> >> On Mon, 2014-08-18 at 16:22 +1000, NeilBrown wrote:
>> >> > Support for loop-back mounted NFS filesystems is useful when NFS is
>> >> > used to access shared storage in a high-availability cluster.
>> >> >
>> >> > If the node running the NFS server fails, some other node can mount the
>> >> > filesystem and start providing NFS service.  If that node already had
>> >> > the filesystem NFS mounted, it will now have it loop-back mounted.
>> >> >
>> >> > nfsd can suffer a deadlock when allocating memory and entering direct
>> >> > reclaim.
>> >> > While direct reclaim does not write to the NFS filesystem it can send
>> >> > and wait for a COMMIT through nfs_release_page().
>> >> >
>> >> > This patch modifies nfs_release_page() and the functions it calls so
>> >> > that if the COMMIT is sent to the local host (i.e. is routed over the
>> >> > loop-back interface) then nfs_release_page() will not wait forever for
>> >> > that COMMIT to complete.  This is achieved using a new flag
>> >> > FLUSH_COND_CONNECTED.  When this is set the flush is conditional and
>> >> > will only wait if the client is connected to a non-local server.
>> >> >
>> >> > Aborting early should be safe as kswapd uses the same code but never
>> >> > waits for the COMMIT.
>> >> >
>> >> > Always aborting early could upset the balance of memory management so
>> >> > when the commit was sent to the local host we still wait but with a
>> >> > 100ms timeout.  This is enough to significantly slow down any process
>> >> > that is allocating lots of memory and often long enough to let the
>> >> > commit complete.
>> >> >
>> >> > In those rare cases where it is nfsd, or something that nfsd is
>> >> > waiting for, that is calling nfs_release_page(), 100ms is not so long
>> >> > that throughput will be seriously affected.
>> >> >
>> >> > When fail-over happens a remote (foreign) client will first become
>> >> > disconnected and then turn into a local client.
>> >> > To prevent deadlocks from happening at this point, we still have a
>> >> > timeout when the COMMIT has been sent to a remote client. In this case
>> >> > the timeout is longer (1 second).
>> >> >
>> >> > So when a node that has mounted a remote filesystem loses the
>> >> > connection, nfs_release_page() will stop blocking and start failing.
>> >> > Memory allocators will then be able to make progress without blocking
>> >> > in NFS.  Any process which writes to a file will still be blocked in
>> >> > balance_dirty_pages().
>> >> >
>> >> > This patch makes use of the new 'private' field in
>> >> > "struct wait_bit_key" to store the start time of a commit, so the
>> >> > 'action' function called by __wait_on_bit() knows how much longer
>> >> > it is appropriate to wait.
>> >> >
>> >>
>> >> This puts way too much RPC connection logic in the NFS layer: we really
>> >> should not have to care. Is there any reason why we could not just use
>> >> RPC_TASK_SOFTCONN to have the commit fail if the connection is broken?
>> >
>> > I tried to keep as much in the RPC layer as I could....
>> >
>> > There really is a big difference between talking to an 'nfsd' on the same
>> > machine and talking to one on a different machine.  In the first case you
>> > need to be cautious of deadlocks, in the second you don't.  That is a
>> > difference that matters to NFS, not to RPC.
>> >
>> > I guess we could always have a timeout, even when connected to a remote
>> > server.  We would just end up blocking somewhere else when the server was not
>> > responding.
>> >
>> > I don't think SOFTCONN is really appropriate.  We don't want the COMMIT to
>> > stop being retried.  We just don't want the memory reclaim code to block
>> > waiting for the COMMIT.
>> >
>> >>
>> >> Note that all this has to come with a huge WARNING: all your data may be
>> >> lost even if you think you just fsync()ed it. Is there any difference
>> >> between doing this and using the 'async' export option on the knfsd
>> >> side?
>> >>
>> >
>> > I don't think this patch risks losing data at all - that certainly isn't the
>> > intent.
>> > This patch only affects the behaviour of ->releasepage, and only allows it to
>> > fail instead of block.  It is perfectly acceptable for releasepage to fail
>> > and it doesn't result in data loss.  It just means that the page is busy.
>> >
>>
>> So why not just change the behaviour of ->releasepage() to always
>> initiate a non-blocking commit and then wait up to 1 second for the
>> PG_private bit to be released?
>>
>
> Would that work?
> PG_private seems to be set when the page is being written, not when the
> COMMIT is happening.
> That is marked with the NFS_INO_COMMIT flag.

The PG_private flag remains set until either the write requests
associated with that page have been committed to stable storage or we
get a fatal error that prevents this from occurring. This is precisely
why we call COMMIT before testing PagePrivate(page) in
nfs_release_page().

> So what my code does is wait a little while for NFS_INO_COMMIT to be released.
>
> I tried to leave the flow largely unchanged for a non-local server and only
> introduced a timeout for a local server.  That probably creates the
> complexity that is bothering you(?).

The layering violations are what bother me; the fact that we're
introducing the concept of transport connection state to the NFS
layer. That kind of concept should be hidden deep in the bowels of the
transport sub-layer of the RPC client code so that we do not have to
worry, when debugging an issue with a hard mount, about whether or not
the client was using TCP or UDP, and what the state was of the
connection.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

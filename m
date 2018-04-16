Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44938 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751199AbeDPV3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Apr 2018 17:29:44 -0400
Date: Mon, 16 Apr 2018 17:29:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Subject: Re: nfsd issue with a kerberized callback
Message-ID: <20180416212942.GA2634@parsley.fieldses.org>
References: <680B7A1A-792A-4B9E-A0CA-46E459B65077@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <680B7A1A-792A-4B9E-A0CA-46E459B65077@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2018 at 03:48:49PM -0400, Olga Kornievskaia wrote:
> I have a failure that I’m investigating from the Bakeathon (this was
> going against redhat-75 server. Not sure who was running that server.
> But I believe that was RHEL7.5 server). I have a network trace and I
> was wondering if you could help with what the server is doing.
>
> I’m attaching a network trace. The parts I’m interested in explaining
> have to do with the kerberized backchannel for NFS4.0.
> 
> A setup is client doing v3 and v4 mount and opening file with one
> version and appending to it with a different version. Its opened with
> 4.0 and got a delegation and it’s trying to write with v3 and server
> is recalling a delegation
> 
> Server is issuing CB_NULL gss_init trying to establish a gss context.
> But it’s doing it twice in frame 259 and frame 261. It’s weird that
> it’s doing it twice. But Ok.

I also wonder why the client sent two sets of
SETCLIENTID/SETCLIENTID_CONFIRM calls.  The second gets back the same
clientid as the first, so I think the only thing the server might do is
update the callback information--but the callback information is the
same in both cases.  Maybe some server bug is causing it not to handle
that update correctly?

I also expect the server to start a CB_NULL as soon as it gets the
setclientid_confirm, so I would have expected to see that sooner.

> Now in frame, 283 it sends CB_COMPOUND CB_RECALL And in frame 285 it
> sends CB_NULL with gss_data with the CB_NULL as the payload. I think
> this is to establish the callback.
> 
> In frame 287, client responds with RPC accept state of 6000 (which I
> believe is "drop reply").

That value shouldn't ever appear on the wire.

Looks like RHEL7 may need 0533b13072f4 "svc: Avoid garbage replies when
pc_func() returns rpc_drop_reply".

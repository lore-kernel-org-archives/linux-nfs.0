Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbbC0RnP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 13:43:15 -0400
Date: Fri, 27 Mar 2015 13:43:12 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 state manager loop on recallable state revoked
In-Reply-To: <alpine.OSX.2.19.9992.1502181212250.80359@planck.local>
Message-ID: <alpine.OSX.2.19.9992.1503271340180.710@planck.local>
References: <alpine.OSX.2.19.9992.1502180937030.80359@planck.local> <CAHQdGtQaj99Sy0qOUky2uE7XX0UXbJOC8LXNvDANzbc1Adio7A@mail.gmail.com> <alpine.OSX.2.19.9992.1502181212250.80359@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Feb 2015, Benjamin Coddington wrote:

> On Wed, 18 Feb 2015, Trond Myklebust wrote:
> > On Wed, Feb 18, 2015 at 8:22 AM, Benjamin Coddington
> > <bcodding@redhat.com> wrote:
> > > While playing with callback channel failures, I noticed the state manager
> > > get stuck looping trying to check a lease when the server responds with
> > > SEQ4_STATUS_RECALLABLE_STATE_REVOKED set.
> > >
> > > Does this look familiar to anyone?
> > >
> > > [67732.348087] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > > [67732.369726] nfs4_free_slot: slotid 2 highest_used_slotid 1
> > > [67732.372881] nfs4_free_slot: slotid 0 highest_used_slotid 1
> > > [67732.375337] nfs4_schedule_state_renewal: requeueing work. Lease period = 5
> > > [67732.394736] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > > [67732.401010] nfs4_free_slot: slotid 0 highest_used_slotid 1
> > > [67732.402910] nfs4_free_slot: slotid 1 highest_used_slotid 4294967295
> > > [67732.404659] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server fedora
> > > [67732.422848] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > > [67732.426257] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > > [67732.427250] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > > [67732.428291] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000041
> > > [67732.429596] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > > [67732.430746] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > > [67732.431817] nfs4_recovery_handle_error: handled error 0 for server fedora
> > > [67732.439132] nfs4_bind_conn_to_session: bind_conn_to_session was successful for server fedora!
> > > [67732.451098] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > > [67732.454522] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > > [67732.455557] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > > [67732.456647] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
> > > [67732.457986] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > > [67732.459215] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > > [67732.460350] nfs4_recovery_handle_error: handled error 0 for server fedora
> > > [67732.472138] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > > [67732.475707] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > > [67732.476779] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > > [67732.477917] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
> > > [67732.479294] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > > [67732.480572] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > > [67732.481753] nfs4_recovery_handle_error: handled error 0 for server fedora
> > > [67732.493666] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > > [67732.497269] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > > [67732.498402] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > > [67732.499563] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
> > > [67732.500894] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > > [67732.502159] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > >
> > > I think what's happening is that we never get to reclaim_lease() because
> > > NFS4CLNT_LEASE_EXPIRED is never flagged.  Should we set
> > > NFS4CLNT_LEASE_EXPIRED in nfs41_handle_cb_path_down()?  I think that would
> > > have avoided this.
> >
> > I don't understand Why would the server reply NFS4ERR_OK to the
> > sequence operation if the lease has expired?
> > Right now, we assume that the server is doing the right thing w.r.t.
> > the lease, so instead, we call BIND_CONN_TO_SESSION with a request
> > that the fore and back channel be associated to this TCP connection.
>
> I may have oversimplified.. let me see if I can explain.
>
> There's netfilter rules using ESTABLISHED,RELATED on the client, and I've
> tuned down nf_conntrack's established and time_wait timeouts to 10 seconds.
>
> echo 10 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
> echo 10 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_time_wait
>
> That causes netfilter to prune the connection tracking so that callbacks
> fail if the client has been idle for 10 seconds or more.  It also means that
> as soon as the client transmits, the callback channel is "repaired".
>
> So the client gets a delegation, and after 10 seconds the server tries to
> call it back (because I wrote to the file), only to find the callback channel
> is down.
>
> Then, the client tries to renew the lease, and a retransmit of the callback
> makes it through, but this is after the server has decided the callback
> channel is down.  This is the point where I get lost in the state manager
> code.
>
> I think that the client tries to recover the delegation, gets BAD_STATEID,
> which should cause us to reclaim open state, eventually leading to freeing
> of the stateid.. but that doesn't happen.  I think because
> NFS4CLNT_CHECK_LEASE is already set without NFS4CLNT_LEASE_EXPIRED, so we
> cannot get to nfs4_do_reclaim().  Since the server never gets a
> FREE_STATEID, it will always set SEQ4_STATUS_RECALLABLE_STATE_REVOKED.
>
> Here's the network cap overview.. let me know if you'd like the whole thing.
> The interesting bit is around frame 193.

Hi Trond,

b04b22f NFSv4: Ensure that we don't reap a delegation that is being returned
ade0464 NFSv4: Ensure we honour NFS_DELEGATION_RETURNING in nfs_inode_set_delegation()
9f0f8e1 NFSv4: Pin the superblock while we're returning the delegation
ec3ca4e NFSv4: Ensure we skip delegations that are already being returned

These fix things up so that it seems I can no longer reproduce this problem.  Thanks!

Ben

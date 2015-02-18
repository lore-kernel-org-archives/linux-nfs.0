Date: Wed, 18 Feb 2015 11:22:20 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: nfs4 state manager loop on recallable state revoked
Message-ID: <alpine.OSX.2.19.9992.1502180937030.80359@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

While playing with callback channel failures, I noticed the state manager
get stuck looping trying to check a lease when the server responds with
SEQ4_STATUS_RECALLABLE_STATE_REVOKED set.

Does this look familiar to anyone?

[67732.348087] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
[67732.369726] nfs4_free_slot: slotid 2 highest_used_slotid 1
[67732.372881] nfs4_free_slot: slotid 0 highest_used_slotid 1
[67732.375337] nfs4_schedule_state_renewal: requeueing work. Lease period = 5
[67732.394736] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
[67732.401010] nfs4_free_slot: slotid 0 highest_used_slotid 1
[67732.402910] nfs4_free_slot: slotid 1 highest_used_slotid 4294967295
[67732.404659] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server fedora
[67732.422848] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
[67732.426257] nfs4_free_slot: slotid 1 highest_used_slotid 0
[67732.427250] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[67732.428291] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000041
[67732.429596] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
[67732.430746] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
[67732.431817] nfs4_recovery_handle_error: handled error 0 for server fedora
[67732.439132] nfs4_bind_conn_to_session: bind_conn_to_session was successful for server fedora!
[67732.451098] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
[67732.454522] nfs4_free_slot: slotid 1 highest_used_slotid 0
[67732.455557] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[67732.456647] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
[67732.457986] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
[67732.459215] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
[67732.460350] nfs4_recovery_handle_error: handled error 0 for server fedora
[67732.472138] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
[67732.475707] nfs4_free_slot: slotid 1 highest_used_slotid 0
[67732.476779] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[67732.477917] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
[67732.479294] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
[67732.480572] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
[67732.481753] nfs4_recovery_handle_error: handled error 0 for server fedora
[67732.493666] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
[67732.497269] nfs4_free_slot: slotid 1 highest_used_slotid 0
[67732.498402] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[67732.499563] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
[67732.500894] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
[67732.502159] nfs4_schedule_state_renewal: requeueing work. Lease period = 60

I think what's happening is that we never get to reclaim_lease() because
NFS4CLNT_LEASE_EXPIRED is never flagged.  Should we set
NFS4CLNT_LEASE_EXPIRED in nfs41_handle_cb_path_down()?  I think that would
have avoided this.

Ben

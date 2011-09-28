Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab1I1BkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 21:40:06 -0400
Date: Tue, 27 Sep 2011 21:40:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/25] nfsd4: extend state lock over seqid replay logic
Message-ID: <20110928014004.GF12190@pad.fieldses.org>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
 <1316000721-3289-4-git-send-email-bfields@redhat.com>
 <4E82001C.5030005@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E82001C.5030005@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 27, 2011 at 12:55:56PM -0400, Bryan Schumaker wrote:
> Hi Bruce,
> 
> I'm getting the following warning that I was able to bisect to this patch:

Hm.  Was it doing a LOCKU at the time, I wonder?  It looks like I missed
a case here....  I'll investigate.

--b.

> 
> [  142.149710] ------------[ cut here ]------------
> [  142.150014] WARNING: at kernel/mutex-debug.c:78 debug_mutex_unlock+0xda/0xe0()
> [  142.150258] Hardware name: Bochs
> [  142.150407] Modules linked in: md5 nfsd exportfs nfs lockd fscache auth_rpcgss nfs_acl sunrpc ipv6 ext2 snd_hda_intel snd_hda_codec snd_hwdep psmouse i2c_piix4 evdev serio_raw pcspkr virtio_balloon snd_pcm snd_timer snd soundcore snd_page_alloc floppy i2c_core button processor ext4 mbcache jbd2 crc16 pata_acpi uhci_hcd ata_piix libata usbcore scsi_mod virtio_net virtio_pci virtio_blk virtio virtio_ring
> [  142.152927] Pid: 742, comm: nfsd Not tainted 3.1.0-rc1-SLIM+ #9
> [  142.152927] Call Trace:
> [  142.152927]  [<ffffffff8105fa4f>] warn_slowpath_common+0x7f/0xc0
> [  142.152927]  [<ffffffff8105faaa>] warn_slowpath_null+0x1a/0x20
> [  142.152927]  [<ffffffff810960ca>] debug_mutex_unlock+0xda/0xe0
> [  142.152927]  [<ffffffff813e4200>] __mutex_unlock_slowpath+0x80/0x140
> [  142.152927]  [<ffffffff813e42ce>] mutex_unlock+0xe/0x10
> [  142.152927]  [<ffffffffa03bd3f5>] nfs4_lock_state+0x35/0x40 [nfsd]
> [  142.152927]  [<ffffffffa03b0b71>] nfsd4_proc_compound+0x2a1/0x690 [nfsd]
> [  142.152927]  [<ffffffffa039f9fb>] nfsd_dispatch+0xeb/0x230 [nfsd]
> [  142.152927]  [<ffffffffa02b1055>] svc_process_common+0x345/0x690 [sunrpc]
> [  142.152927]  [<ffffffff81058d10>] ? try_to_wake_up+0x280/0x280
> [  142.152927]  [<ffffffffa02b16e2>] svc_process+0x102/0x150 [sunrpc]
> [  142.152927]  [<ffffffffa039f0bd>] nfsd+0xbd/0x160 [nfsd]
> [  142.152927]  [<ffffffffa039f000>] ? 0xffffffffa039efff
> [  142.152927]  [<ffffffff8108230c>] kthread+0x8c/0xa0
> [  142.152927]  [<ffffffff813e8694>] kernel_thread_helper+0x4/0x10
> [  142.152927]  [<ffffffff81082280>] ? kthread_worker_fn+0x190/0x190
> [  142.152927]  [<ffffffff813e8690>] ? gs_change+0x13/0x13
> [  142.152927] ---[ end trace 1b4070dc432138aa ]---
> 
> I can duplicate it with this python script, the warning shows up on the server after (during?) the f.close() line:
> 
> #!/usr/bin/python
> import sys
> import fcntl
> import struct
> import datetime
> 
> f = open(sys.argv[1], 'rw+')
> print "Attempting to lock file:", sys.argv[1]
> lockreq = struct.pack('hhllhh', fcntl.F_WRLCK, 0, 0, 0, 0, 0)
> rv = fcntl.fcntl(f, fcntl.F_SETLKW, lockreq)
> raw_input("Press enter when you are ready to continue... ")
> f.close()
> 
> - Bryan
> 
> On 09/14/2011 07:44 AM, J. Bruce Fields wrote:
> > There are currently a couple races in the seqid replay code: a
> > retransmission could come while we're still encoding the original reply,
> > or a new seqid-mutating call could come as we're encoding a replay.
> > 
> > So, extend the state lock over the encoding (both encoding of a replayed
> > reply and caching of the original encoded reply).
> > 
> > I really hate doing this, and previously added the stateowner
> > reference-counting code to avoid it (which was insufficient)--but I
> > don't see a less complicated alternative at the moment.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4proc.c  |    5 +++--
> >  fs/nfsd/nfs4state.c |   12 ++++++++----
> >  2 files changed, 11 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 50bae74..50063a8 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -408,8 +408,8 @@ out:
> >  	if (open->op_stateowner) {
> >  		nfs4_get_stateowner(open->op_stateowner);
> >  		cstate->replay_owner = open->op_stateowner;
> > -	}
> > -	nfs4_unlock_state();
> > +	} else
> > +		nfs4_unlock_state();
> >  	return status;
> >  }
> >  
> > @@ -1227,6 +1227,7 @@ encode_op:
> >  			be32_to_cpu(status));
> >  
> >  		if (cstate->replay_owner) {
> > +			nfs4_unlock_state();
> >  			nfs4_put_stateowner(cstate->replay_owner);
> >  			cstate->replay_owner = NULL;
> >  		}
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index bc1a9db..6cf729a 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3501,7 +3501,8 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  
> >  	nfsd4_create_clid_dir(sop->so_client);
> >  out:
> > -	nfs4_unlock_state();
> > +	if (!cstate->replay_owner)
> > +		nfs4_unlock_state();
> >  	return status;
> >  }
> >  
> > @@ -3568,7 +3569,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
> >  	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
> >  	status = nfs_ok;
> >  out:
> > -	nfs4_unlock_state();
> > +	if (!cstate->replay_owner)
> > +		nfs4_unlock_state();
> >  	return status;
> >  }
> >  
> > @@ -3609,7 +3611,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	if (list_empty(&so->so_stateids))
> >  		move_to_close_lru(so);
> >  out:
> > -	nfs4_unlock_state();
> > +	if (!cstate->replay_owner)
> > +		nfs4_unlock_state();
> >  	return status;
> >  }
> >  
> > @@ -4071,7 +4074,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  out:
> >  	if (status && lock->lk_is_new && lock_sop)
> >  		release_lockowner(lock_sop);
> > -	nfs4_unlock_state();
> > +	if (!cstate->replay_owner)
> > +		nfs4_unlock_state();
> >  	return status;
> >  }
> >  
> 

From: Paul Collins <paul@burly.ondioline.org>
Subject: Re: 2.6.31-rc2 soft lockups; traces point at rpc_wake_up, nfs4_run_state_manager, bit_waitqueue
Date: Mon, 06 Jul 2009 09:25:07 +1200
Message-ID: <8763e6aklo.fsf@jenny.ondioline.org>
References: <87eisv7g5p.fsf@bulky.wgtn.ondioline.org>
	<20090705081225.GA12783@elte.hu>
	<1246800661.5937.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755624AbZGEVZT@vger.kernel.org>
In-Reply-To: <1246800661.5937.1.camel@heimdal.trondhjem.org> (Trond
	Myklebust's message of "Sun, 05 Jul 2009 09:31:01 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> writes:

> On Sun, 2009-07-05 at 10:12 +0200, Ingo Molnar wrote:
>> (added more Cc:s)
>> 
>> potential suspects are:
>> 
>> 1f84603: Merge branch 'devel-for-2.6.31' into for-2.6.31
>> 3f09df7: NFS: Ensure we always hold the BKL when dereferencing inode->i_flock
>> 965b5d6: NFSv4: Handle more errors when recovering open file and locking state
>> 34dc1ad: nfs41: increment_{open,lock}_seqid
>> 78722e9: nfs41: only retry EXCHANGE_ID on recoverable errors
>> b4b8260: nfs41: get_clid_cred for EXCHANGE_ID
>> 90a1661: nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
>> 591d71c: nfs41: establish sessions-based clientid
>> a7b7210: nfs41: introduce get_state_renewal_cred
>> 8e69514f: nfs41: support minorversion 1 for nfs4_check_lease
>> c3fad1b: nfs41: add session reset to state manager
>> 76db6d95: nfs41: add session setup to the state manager
>> c2e713d: nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
>
> Or possibly either rpc.gssd or rpc.idmapd dying. Have you checked to see
> if they are up and running correctly?

I hadn't checked because my NFS4 setup has been solid for a while now.
But I'll give it a lash again.  I don't have NFS 4.1 support enabled,
which may eliminate some of the commits above from consideration.

        Paul

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:37042 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757671Ab3HMMLF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Aug 2013 08:11:05 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so6465657wgg.0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 05:11:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130813115213.GG2395@fieldses.org>
References: <CA+uAZNMXLXcV6VNqOqVJEbOoKwj-fdmBp4mLz25W7nRxaB9A9w@mail.gmail.com>
	<CA+uAZNMgUQ7mWQOeD4EGcgWfwhUFeaBrXregUmbNP15gt2-yjw@mail.gmail.com>
	<20130625212137.GF17511@fieldses.org>
	<CA+uAZNO-C2MOOFhVwAEwU_WineaCNTuRpzdG_8+mHU_BSnrkdw@mail.gmail.com>
	<20130813115213.GG2395@fieldses.org>
Date: Tue, 13 Aug 2013 17:41:03 +0530
Message-ID: <CA+uAZNMj3C2JqJXXV7zePS7L_oasXH6AVkps9HEq7gLqcJqVhA@mail.gmail.com>
Subject: Re: NFSD server is constantly returning nfserr_bad_stateid on 3.2 kernel
From: Shyam Kaushik <shyamnfs1@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yep its fixed in the IDR rewrite.

--Shyam

On Tue, Aug 13, 2013 at 5:22 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Aug 13, 2013 at 12:48:01PM +0530, Shyam Kaushik wrote:
>> Hi Bruce,
>>
>> I managed to nail this issue down. We have a flaw in IDR that it wraps
>> around at 2^30. See this chain for more on it
>> http://comments.gmane.org/gmane.linux.kernel/1543273
>
> Looks like this got fixed by the recent IDR rewrite?
>
> --b.
>
>> Unfortunately NFSD wraps around at MAX_INT which is currently flawed.
>>
>> I added debug within NFSD as you suggested & here are the snippets
>>
>> NFS client came & did an open of file
>> Aug 12 11:21:34 srv1 kernel: [377723.629810] nfsv4 compound op #2/5:
>> 18 (OP_OPEN)
>> Aug 12 11:21:34 srv1 kernel: [377723.629812] NFSD: nfsd4_open filename
>> exports op_openowner           (null)
>> Aug 12 11:21:34 srv1 kernel: [377723.629816] [6809] renewing client
>> (clientid 5208f000/000013bf)
>> Aug 12 11:21:34 srv1 kernel: [377723.629827] nfsd: fh_verify(28:
>> 00070001 0000a4c0 00000000 28ffa6c2 854703cf dd60c89a)
>> Aug 12 11:21:34 srv1 kernel: [377723.629833] nfsd: nfsd_lookup(fh 28:
>> 00070001 0000a4c0 00000000 28ffa6c2 854703cf dd60c89a, exports)
>> Aug 12 11:21:34 srv1 kernel: [377723.629837] nfsd: fh_compose(exp
>> fd:01/42176 tmp_export/exports, ino=37203)
>> Aug 12 11:21:34 srv1 kernel: [377723.629842] nfsd: fh_verify(36:
>> 01070001 0000a4c0 00000000 28ffa6c2 854703cf dd60c89a)
>> Aug 12 11:21:34 srv1 kernel: [377723.629850] nfsd: fh_verify(36:
>> 01070001 0000a4c0 00000000 28ffa6c2 854703cf dd60c89a)
>> Aug 12 11:21:34 srv1 kernel: [377723.629857] [6809] NFSD
>> get_new_stid(5208f000/000013bf/40174d7e/ffff8802)
>> min_stateid[1075268991]/new_stid[1075268991]/error[0]
>> Aug 12 11:21:34 srv1 kernel: [377723.629862] [6809]
>> nfsd4_process_open2: stateid=(5208f000/000013bf/40174d7f/00000001)
>> Aug 12 11:21:34 srv1 kernel: [377723.629866] nfsv4 compound op
>> ffff8801f2015078 opcnt 5 #2: 18: status 0
>>
>> As seen above min_stateid (1075268991) is what we ask IDR to use
>> minimum ID to allocate & it also allocated this same number.
>>
>> After this open, NFS client sends an OPEN_CONFIRM
>> Aug 12 11:21:34 srv1 kernel: [377723.630528] nfsv4 compound op #2/2:
>> 20 (OP_OPEN_CONFIRM)
>> Aug 12 11:21:34 srv1 kernel: [377723.630530] [6809] NFSD:
>> nfsd4_open_confirm on file exports
>> Aug 12 11:21:34 srv1 kernel: [377723.630534] nfsd: fh_verify(36:
>> 01070001 0000a4c0 00000000 28ffa6c2 854703cf dd60c89a)
>> Aug 12 11:21:34 srv1 kernel: [377723.630538] [6809] NFSD:
>> nfs4_preprocess_seqid_op: seqid=11033 stateid =
>> (5208f000/000013bf/40174d7f/00000001)
>> Aug 12 11:21:34 srv1 kernel: [377723.630542] [6809] renewing client
>> (clientid 5208f000/000013bf)
>> Aug 12 11:21:34 srv1 kernel: [377723.630549] [6809] bad_stateid -
>> nfsd4_lookup_stateid: (5208f000/000013bf/40174d7f/00000001) -
>> find_stateid_by_type() returned NULL. find_stateid() returned[NULL]
>> stid->sc_type[0x0] typemask[0x1]
>> Aug 12 11:21:34 srv1 kernel: [377723.630551] nfsv4 compound op
>> ffff8801f2015078 opcnt 2 #2: 20: status 10025
>> Aug 12 11:21:34 srv1 kernel: [377723.630554] nfsv4 compound returned 10025
>>
>> As can be seen, we cant locate 40174d7f in IDR repository.
>>
>> With debug infrastructure, dumped all the IDs of NFSD in IDR repository
>>
>> Aug 12 11:21:34 srv1 kernel: [377723.631994] NFSD: Dumping Confirmed
>> ID hashtable clients
>> Aug 12 11:21:34 srv1 kernel: [377723.632000] NFSD:
>> Client[conf_id_hashtbl] [5208f000/000013bf]
>> Aug 12 11:21:34 srv1 kernel: [377723.632006]       NFSD:
>> [5208f000/000013bf] IDR ID[1527167]
>> (5208f000/000013bf/40174d7f/00000001) sc_type[1]
>> Aug 12 11:21:34 srv1 kernel: [377723.632048]       NFSD: openowner
>> [ffff88010b31ef50] oo_flags[0] so_seqid[11033] so_is_open_owner[1]]
>> Aug 12 11:21:34 srv1 kernel: [377723.632052]               NFSD:
>> nfs4_file stp[ffff88020ae36690] (5208f000/000013bf/40174d7f/00000001)
>> sc_type[1] in zshare_id[1]
>> Aug 12 11:21:34 srv1 kernel: [377723.632059] NFSD: Finished Dumping
>> Confirmed ID hashtable clients
>>
>> IDR has the ID as 1527167 for 0x40174d7f (1075268991)
>>
>> i.e. IDR has representation like
>>
>> 1075268991 – 1073741824 (2^30) = 1527167
>>
>> Is it possible that you can fix NFSD till a proper fix is available in
>> IDR? Thanks.
>>
>> --Shyam
>>
>>
>> On Wed, Jun 26, 2013 at 2:51 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Tue, Jun 25, 2013 at 10:29:00PM +0530, Shyam Kaushik wrote:
>> >> Hi,
>> >>
>> >> I looked up at this issue further & see the problem is this:
>> >> # Client sends OPEN() of a file & as part of this NFSD server sets up
>> >> a stateid & returns to the client.
>> >> # Client comes back immediately with OPEN_CONFIRM() presenting the
>> >> same stateid & NFSD server replies back that its a bad-stateid.
>> >>
>> >> Here are some pieces from tcpdump:
>> >> NFS client comes with an OPEN of a file
>> >> 10.189253 10.0.27.163 172.31.240.116 NFS 326 V4 Call (Reply In 8264)
>> >> OPEN DH:0xfe4b0254/index.html
>> >>          share_access: OPEN4_SHARE_ACCESS_READ (1)
>> >>          share_deny: OPEN4_SHARE_DENY_NONE (0)
>> >>          clientid: 0xcb76ab5114000000
>> >>          Claim Type: CLAIM_NULL (0)
>> >>
>> >> NFS server reply
>> >> 10.457226 172.31.240.116 10.0.27.163 NFS 498 V4 Reply (Call In 8057)
>> >> OPEN StateID:0x50ee
>> >>         Status: NFS4_OK (0)
>> >>         StateID Hash: 0x50ee
>> >>         seqid: 0x00000001
>> >>         Data: cb76ab5114000000c4ca2540
>> >>         1. = OPEN4_RESULT_CONFIRM
>> >>         Delegation Type: OPEN_DELEGATE_NONE (0)
>> >>
>> >>
>> >> Client comes back with OPEN_CONFIRM
>> >> 10.459343 10.0.27.163 172.31.240.116 NFS 238 V4 Call (Reply In 8465)
>> >> OPEN_CONFIRM
>> >>         StateID Hash: 0x50ee
>> >>         seqid: 0x00000001
>> >>         Data: cb76ab5114000000c4ca2540
>> >>
>> >> Server replies with bad-stateid
>> >> 10.733341 172.31.240.116 10.0.27.163 NFS 122 V4 Reply (Call In 8275)
>> >> OPEN_CONFIRM Status: NFS4ERR_BAD_STATEID
>> >>         Status: NFS4ERR_BAD_STATEID (10025)
>> >
>> > That does look like a server bug.  But I have trouble seeing how that's
>> > happening (or why you would be able to reproduce it and not me).
>> >
>> > On the final OPEN_CONFIRM the server is either failing to find the
>> > stateid or found it and thinks it's been closed or already confirmed.
>> >
>> > This is a different case from the one below where the server returns
>> > BAD_STATEID on the write.
>> >
>> >> This keeps happening & nothing really progresses.
>> >>
>> >> Any thoughts/ideas on how to debug this further greatly appreciated.
>> >
>> > Off hand all I can suggest is tracing through the code (worst case,
>> > sprinkling some printk's around) to figure out exactly where the
>> > bad_stateid is being returned from originally.
>> >
>> > Or running a git bisect if you have a known-good kernel.
>> >
>> > Or if there's anything particular about your workload that you could
>> > tell us so someone else could attempt to reproduce it.
>> >
>> > Also it's interesting if you can verify whether this is reproduceable on
>> > newer kernels.
>> >
>> > --b.
>> >
>> >>
>> >> Thanks.
>> >>
>> >> --Shyam
>> >>
>> >> On Mon, Jun 24, 2013 at 10:43 PM, Shyam Kaushik <shyamnfs1@gmail.com> wrote:
>> >> > Hi Folks,
>> >> >
>> >> > Need help regarding a strange NFS server issue on 3.2 kernel.
>> >> >
>> >> > We are running a NFS server on Ubuntu precise with 3.2.0-25-generic
>> >> > #40-Ubuntu kernel.
>> >> >
>> >> > We have several NFS exports out of this server & multiple clients
>> >> > running different versions of linux kernel consume these exports. We
>> >> > use ext4 with sync mount as the filesystem.
>> >> >
>> >> > We periodically see that all NFS activity comes to a standstill on all
>> >> > NFS exports. Enabling NFS debug shows that there are numerous
>> >> > nfserr_bad_stateid on almost all operations. This makes all of the
>> >> > NFSD threads to consume all of CPU on the server.
>> >> >
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342457] nfsd_dispatch: vers 4 proc 1
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342457] nfsv4 compound op
>> >> > #1/7: 22 (OP_PUTFH)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342467] nfsv4 compound op
>> >> > ffff880095744078 opcnt 3 #1: 22: status 0
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342472] nfsv4 compound op
>> >> > #2/3: 38 (OP_WRITE)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342472] nfsd: fh_verify(36:
>> >> > 01070001 00d40001 00000000 ac63c188 0a4859a1 feb41e83)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342484] renewing client
>> >> > (clientid 51ab76cb/00005fc9)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342486] NFSD: nfsd4_write:
>> >> > couldn't process stateid!
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342529] nfsv4 compound op
>> >> > ffff880095744078 opcnt 3 #2: 38: status 10025
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.342544] nfsv4 compound returned 10025
>> >> >
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.444116] nfsd_dispatch: vers 4 proc 1
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.444122] nfsv4 compound op
>> >> > #1/3: 22 (OP_PUTFH)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.444125] nfsd: fh_verify(36:
>> >> > 01070001 00020001 00000000 eb3726ca c8497c28 911b4a8d)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.444134] nfsv4 compound op
>> >> > ffff880093436078 opcnt 3 #1: 22: status 0
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.444136] nfsv4 compound op
>> >> > #2/3: 38 (OP_WRITE)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.446920] nfsd4_process_open2:
>> >> > stateid=(51ab76cb/0000000b/40259544/00000001)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.446925] nfsv4 compound op
>> >> > ffff880095027078 opcnt 7 #3: 18: status 0
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.446929] renewing client
>> >> > (clientid 51ab76cb/00000022)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.446929] NFSD: nfsd4_write:
>> >> > couldn't process stateid!
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.446929] nfsv4 compound op
>> >> > ffff880093436078 opcnt 3 #2: 38: status 10025
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.446929] nfsv4 compound returned 10025
>> >> >
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447162] nfsd_dispatch: vers 4 proc 1
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447163] nfsd: fh_verify(36:
>> >> > 01070001 00240001 00000000 a80fc170 1947ae6c 4fbf37b1)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447163] NFSD:
>> >> > nfs4_preprocess_seqid_op: seqid=1 stateid =
>> >> > (51ab76cb/00004b96/40259528/00000001)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447181] nfsv4 compound op
>> >> > #1/7: 22 (OP_PUTFH)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447185] nfsd: fh_verify(28:
>> >> > 00070001 00020001 00000000 53c0b8df a948fcb9 475e2cba)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447185] renewing client
>> >> > (clientid 51ab76cb/00004b96)
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447187] nfsv4 compound op
>> >> > ffff88000813f078 opcnt 2 #2: 20: status 10025
>> >> > Jun 24 01:50:42 srv007 kernel: [5753609.447189] nfsv4 compound returned 10025
>> >> >
>> >> > NFSD stacks are like:
>> >> > [<ffffffffa022e765>] nfs4_lock_state+0x15/0x40 [nfsd]
>> >> > [<ffffffffa02234f4>] nfsd4_open+0xb4/0x440 [nfsd]
>> >> > [<ffffffffa0221bc8>] nfsd4_proc_compound+0x518/0x6d0 [nfsd]
>> >> > [<ffffffffa020fa0b>] nfsd_dispatch+0xeb/0x230 [nfsd]
>> >> > [<ffffffffa0131d95>] svc_process_common+0x345/0x690 [sunrpc]
>> >> > [<ffffffffa01321e2>] svc_process+0x102/0x150 [sunrpc]
>> >> > [<ffffffffa020f0bd>] nfsd+0xbd/0x160 [nfsd]
>> >> > [<ffffffff8108a59c>] kthread+0x8c/0xa0
>> >> > [<ffffffff81667db4>] kernel_thread_helper+0x4/0x10
>> >> > [<ffffffffffffffff>] 0xffffffffffffffff
>> >> >
>> >> > I couldnt exactly capture the running thread, but it appears that one
>> >> > thread of the NFSD thread pool runs & detects a bad-state-id & returns
>> >> > back.
>> >> >
>> >> > Is this a known issue or any help on how to dig in further is greatly
>> >> > appreciated.
>> >> >
>> >> > Thanks.
>> >> >
>> >> > --Shyam
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html

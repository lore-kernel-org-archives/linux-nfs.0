From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Got error -10052 from the server on DESTROY_SESSION. Session
 has 	been destroyed regardless...
Date: Tue, 08 Jun 2010 20:44:22 +0300
Message-ID: <4C0E8176.9090406@panasas.com>
References: <4C0E6C37.3040504@panasas.com> <AANLkTinzsVkmZBAqXxQpBScy71L6DSUlYiRwa_kZAicN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38015 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755757Ab0FHRo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 13:44:26 -0400
In-Reply-To: <AANLkTinzsVkmZBAqXxQpBScy71L6DSUlYiRwa_kZAicN-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2010 07:42 PM, Alexandros Batsakis wrote:
> Any other operations during that time ? Like a COMMIT or a CLOSE maybe?
> 
> -alexandros
> 
> On Tue, Jun 8, 2010 at 9:13 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>> On 2.6.35-rc2-pnfs I get:
>>
>> Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
>>
>> at end of cthon test. And it has hard time umounting. After some seconds it is able to umount
>> Am investigating. Has any one seen this?
>>
>> Boaz
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

I got it in the middle of a test and a freeze:
These are server only traces (echo $((0x7fff)) > /proc/sys/sunrpc/nfsd_debug)

Jun  8 20:18:42 tl1 kernel: fs_layout_return: inode 686 iomode=2 offset=0x0 length=0xffffffffffffffff cookie = ffffffffffffffff flags 0x0 s
tatus=0
Jun  8 20:18:42 tl1 kernel: pNFS nfs4_pnfs_return_layout: exit status 0 
Jun  8 20:18:42 tl1 kernel: pNFS nfsd4_layoutreturn: status 0 return_type 0x1 lrs_present 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcnt 3 #3: 51: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 0
Jun  8 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff880079683800
Jun  8 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT STATE TO AVAILABLE
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/00000006)
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/4: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
Jun  8 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12630 slot_seqid 12629
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 0
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 92, xb->page_len 0 tlen 0 pad 8
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcnt 4 #1: 53: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #2/4: 22 (OP_PUTFH)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002ae 6b39d66c 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 100, xb->page_len 0 tlen 0 pad 8
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcnt 4 #2: 22: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #3/4: 4 (OP_CLOSE)
Jun  8 20:18:42 tl1 kernel: NFSD: nfsd4_close on file nfsidem
Jun  8 20:18:42 tl1 kernel: NFSD: nfs4_preprocess_seqid_op: seqid=0 stateid = (4c0e7a8d/000001a9/00000243/00000001)
Jun  8 20:18:42 tl1 kernel: NFSD: find_stateid flags 0x45
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/00000006)
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 124, xb->page_len 0 tlen 0 pad 8
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcnt 4 #3: 4: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #4/4: 9 (OP_GETATTR)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002ae 6b39d66c 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 180, xb->page_len 0 tlen 0 pad 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcnt 4 #4: 9: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 0
Jun  8 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff880079683800
Jun  8 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT STATE TO AVAILABLE
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/00000006)
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/8: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
Jun  8 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12631 slot_seqid 12630
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 0
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 92, xb->page_len 0 tlen 0 pad 8
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 8 #1: 53: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #2/8: 22 (OP_PUTFH)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002a0 6b39d65e 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 100, xb->page_len 0 tlen 0 pad 8
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 8 #2: 22: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #3/8: 32 (OP_SAVEFH)
Jun  8 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 108, xb->page_len 0 tlen 0 pad 8
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 8 #3: 32: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #4/8: 18 (OP_OPEN)
Jun  8 20:18:42 tl1 kernel: NFSD: nfsd4_open filename rewind op_stateowner (null)
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/00000006)
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/4: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
Jun  8 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12632 slot_seqid 12631
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcnt 4 #1: 53: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #2/4: 22 (OP_PUTFH)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002b4 6b39d672 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcnt 4 #2: 22: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #3/4: 3 (OP_ACCESS)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002b4 6b39d672 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcnt 4 #3: 3: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #4/4: 9 (OP_GETATTR)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002b4 6b39d672 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcnt 4 #4: 9: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 0
Jun  8 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff880079683800
Jun  8 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT STATE TO AVAILABLE
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/00000006)
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 44 (OP_DESTROY_SESSION)
Jun  8 20:18:42 tl1 kernel: nfsd4_destroy_session: 1276017293:5:5:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:5:5:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 5
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_destroy_session returns 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf1078 opcnt 1 #1: 44: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 43 (OP_CREATE_SESSION)
Jun  8 20:18:42 tl1 kernel: nfsd4_create_session returns 10022
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 1 #1: 43: status 10022
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10022
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 42 (OP_EXCHANGE_ID)
Jun  8 20:18:42 tl1 kernel: nfsd4_exchange_id rqstp=ffff880075d6a000 exid=ffff880072cb0080 clname.len=21 clname.data=ffff880072ca2084 ip_ad
dr=127.0.0.1 flags 60001, spa_how 0
Jun  8 20:18:42 tl1 kernel: NFSD: nfs4_make_rec_clidname for 127.0.0.1/127.0.0.1 0
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98a00, fp ffff88007a216958
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f988c0, fp ffff88007a2168a0
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98780, fp ffff88007a216a10
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98640, fp ffff88007a216f18
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98500, fp ffff88007a216e60
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f983c0, fp ffff88007a216da8
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98280, fp ffff88007a216cf0
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
Jun  8 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12633 slot_seqid 12632
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #1: 53: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #2/3: 22 (OP_PUTFH)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002b4 6b39d672 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #2: 22: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #3/3: 50 (OP_LAYOUTGET)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 000002b4 6b39d672 00000000 00000000)
Jun  8 20:18:42 tl1 kernel: nfsd4_encode_layoutget: err 0
Jun  8 20:18:42 tl1 kernel: NFSD: nfs4_pnfs_get_layout Begin
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98000, fp ffff88007a216450
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a2308c0, fp ffff88007a150a10
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a230640, fp ffff88007a150958
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a230780, fp ffff88007a1508a0
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98140, fp ffff88007a216ac8
Jun  8 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a230c80, fp ffff88007a150730
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230c80
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a150730 dp ffff88007a230c80 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a230c80
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98140
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216ac8 dp ffff880072f98140 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98140
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230780
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a1508a0 dp ffff88007a230780 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a230780
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230640
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a150958 dp ffff88007a230640 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a230640
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a2308c0
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a150a10 dp ffff88007a2308c0 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a2308c0
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98000
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216450 dp ffff880072f98000 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98000
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98280
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216cf0 dp ffff880072f98280 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98280
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f983c0
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216da8 dp ffff880072f983c0 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f983c0
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98500
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216e60 dp ffff880072f98500 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98500
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98640
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216f18 dp ffff880072f98640 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98640
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98780
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216a10 dp ffff880072f98780 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98780
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f988c0
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a2168a0 dp ffff880072f988c0 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f988c0
Jun  8 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98a00
Jun  8 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff88007a216958 dp ffff880072f98a00 dl_count 1
Jun  8 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98a00
Jun  8 20:18:42 tl1 kernel: pNFS destroy_layout: lp ffff8800795989c0 clp ffff88007a584000 fp ffff88007a299200 ino ffff880070d53900 ls_layou
ts empty 1
Jun  8 20:18:42 tl1 kernel: pNFS put_layout_state_locked: ls ffff88007a97de40 ls_ref 1
Jun  8 20:18:42 tl1 kernel: pNFS destroy_layout_state_common: ls ffff88007a97de40 fp ffff88007a299200 clp ffff88007a584000
Jun  8 20:18:42 tl1 kernel: pnfs_expire_client: inode 674 lp ffff8800795989c0 clp ffff88007a584000
Jun  8 20:18:42 tl1 kernel: exofs @exofs_layout_return:253: (0x2a2) cookie (null) xdr_len 0
Jun  8 20:18:42 tl1 kernel: fs_layout_return: inode 674 iomode=2 offset=0x0 length=0xffffffffffffffff cookie = (null) flags 0x2 status=0
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000000b)
Jun  8 20:18:42 tl1 kernel: nfsd4_exchange_id seqid 0 flags 60001
Jun  8 20:18:42 tl1 kernel: nfsd4_exchange_id returns 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcnt 1 #1: 42: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 0
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 43 (OP_CREATE_SESSION)
Jun  8 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 1 slot_seqid 0
Jun  8 20:18:42 tl1 kernel: NFSD: move_to_confirm nfs4_client ffff880072f49400
Jun  8 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000000b)
Jun  8 20:18:42 tl1 kernel: init_forechannel_attrs status 0
Jun  8 20:18:42 tl1 kernel: nfsd4_create_session returns 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 1 #1: 43: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 0
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:11:11:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 11
Jun  8 20:18:42 tl1 kernel: list traversal: 1276017293:11:11:0
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
Jun  8 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 1 slot_seqid 0
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 3 #1: 53: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #2/3: 24 (OP_PUTROOTFH)
Jun  8 20:18:42 tl1 kernel: nfsd: fh_compose(exp 00:00/2 ///, ino=2)
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcnt 3 #2: 24: status 0
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #3/3: 9 (OP_GETATTR)
Jun  8 20:18:42 tl1 kernel: pNFS nfs4_pnfs_get_layout: fp ffff880075e43c00 clp (null) 
Jun  8 20:18:42 tl1 kernel: pNFS nfs4_pnfs_get_layout: lp (null) exit nfserr 22
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #3: 50: status 22
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 22
Jun  8 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff880079683800
Jun  8 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT STATE TO AVAILABLE
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: )
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf6078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
un  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf6078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf6078 opcnt 3 #1: 53: status 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound returned 10052
Jun  8 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE)
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:6:0
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
Jun  8 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not found
Jun  8 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
Jun  8 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcnt 3 #1: 53: status 10052

And so on. things get bad after that

Boaz

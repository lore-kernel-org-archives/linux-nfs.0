From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: Got error -10052 from the server on DESTROY_SESSION. Session has
	been destroyed regardless...
Date: Tue, 8 Jun 2010 10:56:39 -0700
Message-ID: <AANLkTimF96pcQl53ZaBdpECe-OBP-JX7lw2zZ3S_1UZ5@mail.gmail.com>
References: <4C0E6C37.3040504@panasas.com>
	<AANLkTinzsVkmZBAqXxQpBScy71L6DSUlYiRwa_kZAicN@mail.gmail.com>
	<4C0E8176.9090406@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f176.google.com ([209.85.222.176]:52939 "EHLO
	mail-pz0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061Ab0FHR4l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 13:56:41 -0400
Received: by pzk6 with SMTP id 6so2365131pzk.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 10:56:40 -0700 (PDT)
In-Reply-To: <4C0E8176.9090406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

can you collect lient traces ? They would be more useful.
The error message you see is not fatal, it happens if the RPC is
killed for some reason (e.g. during umount) or if the request
timeouts. But this trace wasn't collected at umount time, right ?
Also are these the objects client and server ?

-alexandros

On Tue, Jun 8, 2010 at 10:44 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 06/08/2010 07:42 PM, Alexandros Batsakis wrote:
>> Any other operations during that time ? Like a COMMIT or a CLOSE may=
be?
>>
>> -alexandros
>>
>> On Tue, Jun 8, 2010 at 9:13 AM, Boaz Harrosh <bharrosh@panasas.com> =
wrote:
>>>
>>> On 2.6.35-rc2-pnfs I get:
>>>
>>> Got error -10052 from the server on DESTROY_SESSION. Session has be=
en destroyed regardless...
>>>
>>> at end of cthon test. And it has hard time umounting. After some se=
conds it is able to umount
>>> Am investigating. Has any one seen this?
>>>
>>> Boaz
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>
> I got it in the middle of a test and a freeze:
> These are server only traces (echo $((0x7fff)) > /proc/sys/sunrpc/nfs=
d_debug)
>
> Jun =A08 20:18:42 tl1 kernel: fs_layout_return: inode 686 iomode=3D2 =
offset=3D0x0 length=3D0xffffffffffffffff cookie =3D ffffffffffffffff fl=
ags 0x0 s
> tatus=3D0
> Jun =A08 20:18:42 tl1 kernel: pNFS nfs4_pnfs_return_layout: exit stat=
us 0
> Jun =A08 20:18:42 tl1 kernel: pNFS nfsd4_layoutreturn: status 0 retur=
n_type 0x1 lrs_present 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcn=
t 3 #3: 51: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 0
> Jun =A08 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff88=
0079683800
> Jun =A08 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT ST=
ATE TO AVAILABLE
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
0006)
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/4: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
> Jun =A08 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12630 slo=
t_seqid 12629
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 92, xb->pa=
ge_len 0 tlen 0 pad 8
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcn=
t 4 #1: 53: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #2/4: 22 (OP_PUTFH)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002ae 6b39d66c 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 100, xb->p=
age_len 0 tlen 0 pad 8
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcn=
t 4 #2: 22: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #3/4: 4 (OP_CLOSE)
> Jun =A08 20:18:42 tl1 kernel: NFSD: nfsd4_close on file nfsidem
> Jun =A08 20:18:42 tl1 kernel: NFSD: nfs4_preprocess_seqid_op: seqid=3D=
0 stateid =3D (4c0e7a8d/000001a9/00000243/00000001)
> Jun =A08 20:18:42 tl1 kernel: NFSD: find_stateid flags 0x45
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
0006)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 124, xb->p=
age_len 0 tlen 0 pad 8
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcn=
t 4 #3: 4: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #4/4: 9 (OP_GETATTR)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002ae 6b39d66c 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 180, xb->p=
age_len 0 tlen 0 pad 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcn=
t 4 #4: 9: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 0
> Jun =A08 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff88=
0079683800
> Jun =A08 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT ST=
ATE TO AVAILABLE
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
0006)
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/8: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
> Jun =A08 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12631 slo=
t_seqid 12630
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 92, xb->pa=
ge_len 0 tlen 0 pad 8
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 8 #1: 53: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #2/8: 22 (OP_PUTFH)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002a0 6b39d65e 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 100, xb->p=
age_len 0 tlen 0 pad 8
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 8 #2: 22: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #3/8: 32 (OP_SAVEFH)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_check_drc_limit length 108, xb->p=
age_len 0 tlen 0 pad 8
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 8 #3: 32: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #4/8: 18 (OP_OPEN)
> Jun =A08 20:18:42 tl1 kernel: NFSD: nfsd4_open filename rewind op_sta=
teowner (null)
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
0006)
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/4: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
> Jun =A08 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12632 slo=
t_seqid 12631
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcn=
t 4 #1: 53: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #2/4: 22 (OP_PUTFH)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002b4 6b39d672 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcn=
t 4 #2: 22: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #3/4: 3 (OP_ACCESS)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002b4 6b39d672 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcn=
t 4 #3: 3: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #4/4: 9 (OP_GETATTR)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002b4 6b39d672 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcn=
t 4 #4: 9: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 0
> Jun =A08 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff88=
0079683800
> Jun =A08 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT ST=
ATE TO AVAILABLE
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
0006)
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 44 (OP_DESTROY_=
SESSION)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_destroy_session: 1276017293:5:5:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:5=
:5:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 5
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_destroy_session returns 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf1078 opcn=
t 1 #1: 44: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: Got error -10052 from the server on DES=
TROY_SESSION. Session has been destroyed regardless...
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 43 (OP_CREATE_S=
ESSION)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_create_session returns 10022
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 1 #1: 43: status 10022
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10022
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 42 (OP_EXCHANGE=
_ID)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_exchange_id rqstp=3Dffff880075d6a=
000 exid=3Dffff880072cb0080 clname.len=3D21 clname.data=3Dffff880072ca2=
084 ip_ad
> dr=3D127.0.0.1 flags 60001, spa_how 0
> Jun =A08 20:18:42 tl1 kernel: NFSD: nfs4_make_rec_clidname for 127.0.=
0.1/127.0.0.1 0
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f98a0=
0, fp ffff88007a216958
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f988c=
0, fp ffff88007a2168a0
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f9878=
0, fp ffff88007a216a10
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f9864=
0, fp ffff88007a216f18
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f9850=
0, fp ffff88007a216e60
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f983c=
0, fp ffff88007a216da8
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f9828=
0, fp ffff88007a216cf0
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: list traversal: 1276017293:6:6:0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
> Jun =A08 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 12633 slo=
t_seqid 12632
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #1: 53: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #2/3: 22 (OP_PUTFH)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002b4 6b39d672 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #2: 22: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #3/3: 50 (OP_LAYOUTGE=
T)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_verify(16: 01010001 00000000 0=
00002b4 6b39d672 00000000 00000000)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_encode_layoutget: err 0
> Jun =A08 20:18:42 tl1 kernel: NFSD: nfs4_pnfs_get_layout Begin
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f9800=
0, fp ffff88007a216450
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a2308c=
0, fp ffff88007a150a10
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a23064=
0, fp ffff88007a150958
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a23078=
0, fp ffff88007a1508a0
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff880072f9814=
0, fp ffff88007a216ac8
> Jun =A08 20:18:42 tl1 kernel: NFSD: expire client. dp ffff88007a230c8=
0, fp ffff88007a150730
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230=
c80
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a150730 dp ffff88007a230c80 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a230c80
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
140
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216ac8 dp ffff880072f98140 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98140
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230=
780
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a1508a0 dp ffff88007a230780 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a230780
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230=
640
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a150958 dp ffff88007a230640 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a230640
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff88007a230=
8c0
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a150a10 dp ffff88007a2308c0 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff88007a2308c0
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
000
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216450 dp ffff880072f98000 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98000
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
280
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216cf0 dp ffff880072f98280 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98280
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
3c0
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216da8 dp ffff880072f983c0 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f983c0
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
500
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216e60 dp ffff880072f98500 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98500
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
640
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216f18 dp ffff880072f98640 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98640
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
780
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216a10 dp ffff880072f98780 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98780
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
8c0
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a2168a0 dp ffff880072f988c0 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f988c0
> Jun =A08 20:18:42 tl1 kernel: NFSD: close_delegation dp ffff880072f98=
a00
> Jun =A08 20:18:42 tl1 kernel: NFSD nfsd_release_deleg_cb: fl ffff8800=
7a216958 dp ffff880072f98a00 dl_count 1
> Jun =A08 20:18:42 tl1 kernel: NFSD: freeing dp ffff880072f98a00
> Jun =A08 20:18:42 tl1 kernel: pNFS destroy_layout: lp ffff8800795989c=
0 clp ffff88007a584000 fp ffff88007a299200 ino ffff880070d53900 ls_layo=
u
> ts empty 1
> Jun =A08 20:18:42 tl1 kernel: pNFS put_layout_state_locked: ls ffff88=
007a97de40 ls_ref 1
> Jun =A08 20:18:42 tl1 kernel: pNFS destroy_layout_state_common: ls ff=
ff88007a97de40 fp ffff88007a299200 clp ffff88007a584000
> Jun =A08 20:18:42 tl1 kernel: pnfs_expire_client: inode 674 lp ffff88=
00795989c0 clp ffff88007a584000
> Jun =A08 20:18:42 tl1 kernel: exofs @exofs_layout_return:253: (0x2a2)=
 cookie (null) xdr_len 0
> Jun =A08 20:18:42 tl1 kernel: fs_layout_return: inode 674 iomode=3D2 =
offset=3D0x0 length=3D0xffffffffffffffff cookie =3D (null) flags 0x2 st=
atus=3D0
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
000b)
> Jun =A08 20:18:42 tl1 kernel: nfsd4_exchange_id seqid 0 flags 60001
> Jun =A08 20:18:42 tl1 kernel: nfsd4_exchange_id returns 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff880072cb0078 opcn=
t 1 #1: 42: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 0
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/1: 43 (OP_CREATE_S=
ESSION)
> Jun =A08 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 1 slot_se=
qid 0
> Jun =A08 20:18:42 tl1 kernel: NFSD: move_to_confirm nfs4_client ffff8=
80072f49400
> Jun =A08 20:18:42 tl1 kernel: renewing client (clientid 4c0e7a8d/0000=
000b)
> Jun =A08 20:18:42 tl1 kernel: init_forechannel_attrs status 0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_create_session returns 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 1 #1: 43: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 0
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:1=
1:11:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 11
> Jun =A08 20:18:42 tl1 kernel: list traversal: 1276017293:11:11:0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: slotid 0
> Jun =A08 20:18:42 tl1 kernel: check_slot_seqid enter. seqid 1 slot_se=
qid 0
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 3 #1: 53: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #2/3: 24 (OP_PUTROOTF=
H)
> Jun =A08 20:18:42 tl1 kernel: nfsd: fh_compose(exp 00:00/2 ///, ino=3D=
2)
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf7078 opcn=
t 3 #2: 24: status 0
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #3/3: 9 (OP_GETATTR)
> Jun =A08 20:18:42 tl1 kernel: pNFS nfs4_pnfs_get_layout: fp ffff88007=
5e43c00 clp (null)
> Jun =A08 20:18:42 tl1 kernel: pNFS nfs4_pnfs_get_layout: lp (null) ex=
it nfserr 22
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #3: 50: status 22
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 22
> Jun =A08 20:18:42 tl1 kernel: --> nfsd4_store_cache_entry slot ffff88=
0079683800
> Jun =A08 20:18:42 tl1 kernel: nfs4svc_encode_compoundres: SET SLOT ST=
ATE TO AVAILABLE
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a06c078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: )
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf6078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> un =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6:=
6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf6078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007aaf6078 opcn=
t 3 #1: 53: status 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound returned 10052
> Jun =A08 20:18:42 tl1 kernel: nfsd_dispatch: vers 4 proc 1
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op #1/3: 53 (OP_SEQUENCE=
)
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: 1276017293:6=
:6:0
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: idx is 6
> Jun =A08 20:18:42 tl1 kernel: find_in_sessionid_hashtbl: session not =
found
> Jun =A08 20:18:42 tl1 kernel: nfsd4_sequence: return 10052
> Jun =A08 20:18:42 tl1 kernel: nfsv4 compound op ffff88007a1c7078 opcn=
t 3 #1: 53: status 10052
>
> And so on. things get bad after that
>
> Boaz
>

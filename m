Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f182.google.com ([209.85.212.182]:62810 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462Ab3EKCsm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:48:42 -0400
Received: by mail-wi0-f182.google.com with SMTP id m6so1208494wiv.9
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:48:40 -0700 (PDT)
Message-ID: <518DB183.1030801@tonian.com>
Date: Sat, 11 May 2013 05:48:35 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS list <linux-nfs@vger.kernel.org>, Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 0/38] pnfsd: Use layout state to track layouts and misc.
References: <518B6377.3000207@tonian.com> <20130510172930.GB14936@fieldses.org>
In-Reply-To: <20130510172930.GB14936@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-05-10 20:29, J. Bruce Fields wrote:
> On Thu, May 09, 2013 at 11:51:03AM +0300, Benny Halevy wrote:
>> The following patchset includes:
>> - API usage changes that originated in v3.8 around the use of nfsd_net
>>   to search clientid and stateid.
>>   - temporary removal of notify_deviceid and get_state pnfs callback API
>>     until we implement a mechanism to look up global stateids and clientids
>>     provided by the file system.
>> - rewriting of the layout tracking mechanism, using
>>   the layout_state structure to keep a list of all derived layout
>>   and enlisting the layout_state on its respective file and client rather
>>   than the layout structure themselves.
>> - various bug fixes
> 
> Were there supposed to be patches following this?

Duh. I had a typo in the To address. Resent.

> 
> Also, is there some minimal subset of the pnfsd patches that it would
> make sense to start merging some day?

Absolutely.  Let me squash this patchset in and we can look at then
cleaned up pnfsd patchset.  The minimum use case would be either exofs or
the dlm use case.  We can technically separate out the layout recall path
but it won't be real without it.

Benny

> 
> --b.
> 
>>
>> API related reverts:
>> [PATCH 01/38] Revert "SQUASHME: pnfsd: Fix compiler warning when
>> [PATCH 02/38] Revert "pnfsd: Clean up all stateids on DS on
>> [PATCH 03/38] Revert "pnfsd: update ds stateid from mds"
>> [PATCH 04/38] pnfsd-lexp: remove get_state
>> [PATCH 05/38] Revert "FIXME pnfsd: gfs2 temp turn off DS stateid
>> [PATCH 06/38] Revert "pnfsd: nfs4_preprocess_pnfs_ds_stateid"
>> [PATCH 07/38] Revert "pnfsd: Add way of determining if a client has
>> [PATCH 08/38] Revert "pnfsd: Notify device ID changes"
>> [PATCH 09/38] Revert "pnfsd: filelayout: file layout specific
>> [PATCH 10/38] Revert "pnfsd: Use ds_state_lock to protect retrieving
>> [PATCH 11/38] Revert "pnfsd: ds state"
>> [PATCH 12/38] Revert "pnfsd: decode getdeviceinfo notify types."
>> [PATCH 13/38] Revert "pnfsd: set_device_notify"
>> [PATCH 14/38] FIXME: temporarily disable create_layout_recall_list
>>
>> API related changes:
>> [PATCH 15/38] SQUASHME: pnfsd: use nfsd_net for layoutget starting
>> [PATCH 16/38] SQUASHME: pnfsd: use nfsd4_init_callback starting v3.8
>> [PATCH 17/38] SQUASHME: use nfsd_net for layoutreturn starting v3.8
>>
>> bug fixes:
>> [PATCH 18/38] SQUASHME: pnfsd: fix destroy_layout_state
>> [PATCH 19/38] SQUASHME: pnfsd: get rid of depdency on nfsd_serv
>> [PATCH 20/38] SQUASHME: pnfsd: merge_layout needs to acquire the
>> [PATCH 21/38] SQUASHME: pnfsd: return bool from merge_layout and fix
>> [PATCH 22/38] SQUASHME: pnfsd: hanging nfs4_layoutrecall on the
>> [PATCH 23/38] DEBUG: pnfsd: ASSERT_LAYOUT_LOCKED
>> [PATCH 24/38] pnfsd: cause oops when stop the nfs server
>>
>> layout tracking:
>> [PATCH 25/38] pnfsd: layout state: rename fi_layout_states member
>> [PATCH 26/38] pnfsd: layout state: move initialization of ls_roc
>> [PATCH 27/38] pnfsd: layout state: introduce ls_file backpointer
>> [PATCH 28/38] pnfsd: layout state: introduce ls_client backpointer
>> [PATCH 29/38] pnfsd: layout state: hang layouts on layout state
>> [PATCH 30/38] pnfsd-lexp: fixup recall_layout
>> [PATCH 31/38] pnfsd: use the layout stateid for layout recalls
>> [PATCH 32/38] pnfsd: cosmetic fixes
>> [PATCH 33/38] pnfsd: pass layout stateid down to fs on layoutget
>> [PATCH 34/38] pnfsd: pass layout stateid down to fs on layoutreturn
>> [PATCH 35/38] pnfsd: use layout stateid for is_layout_recalled
>> [PATCH 36/38] pnfsd: deprecate cbl_seg.clientid
>> [PATCH 37/38] pnfsd: don't use clientid in merge_layout
>> [PATCH 38/38] pnfsd: remove clientid member from struct
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

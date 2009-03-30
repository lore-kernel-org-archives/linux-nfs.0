From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 09/46] nfs41: sessions client infrastructure
Date: Mon, 30 Mar 2009 11:30:29 +0300
Message-ID: <49D08325.3090703@panasas.com>
References: <49ADBD04.2090002@panasas.com>	 <1236124392-3220-1-git-send-email-bhalevy@panasas.com> <1238344265.10999.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2142 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753305AbZC3IbN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 04:31:13 -0400
In-Reply-To: <1238344265.10999.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 19:31 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2009-03-03 at 16:53 -0700, Benny Halevy wrote:
>> From: Andy Adamson <andros@netapp.com>
<snip>
>> +static int nfs4_init_slot_table(struct nfs4_session *session)
> 
> This function isn't used anywhere. Why is it being defined in this
> patch?

Yeah, I'll move its definition to first usage (create_session)

> 
>> +{
>> +       struct nfs4_slot_table *tbl = &session->fc_slot_table;
>> +       int i, max_slots = session->fc_attrs.max_reqs;
>> +       struct nfs4_slot *slot;
>> +       int ret = -ENOMEM;
>> +
>> +       BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
>> +
>> +       dprintk("--> %s: max_reqs=%u\n", __func__,
>> +               session->fc_attrs.max_reqs);
>> +
>> +       slot = kzalloc(max_slots * sizeof(struct nfs4_slot),
>> GFP_ATOMIC);
> 
> Please use kcalloc() when allocating an array. Also, you need a strong
> justification for why this has to be a GFP_ATOMIC allocation.

OK.  I think that GP_ATOMIC was just an overlook.
Will change to GFP_KERNEL.


>> +struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
>> +{
>> +       struct nfs4_session *session;
>> +       struct nfs4_slot_table *tbl;
>> +
>> +       session = kzalloc(sizeof(struct nfs4_session), GFP_ATOMIC);
> 
> I can see no reason why this needs to be a GFP_ATOMIC allocation.

ditto.

Thanks!

Benny

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:39500 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964978Ab2FAQT0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 12:19:26 -0400
Subject: Re: [PATCH 2/4] NFS: Properly sort TEST_STATEID results
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1338566483.2774.22.camel@lade.trondhjem.org>
Date: Fri, 1 Jun 2012 12:19:15 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <1764FCF4-A0C9-4DEA-A6D0-5CCF7A6048D0@oracle.com>
References: <20120601153231.5626.89559.stgit@degas.1015granger.net> <20120601153814.5626.16055.stgit@degas.1015granger.net> <1338566483.2774.22.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 1, 2012, at 12:01 PM, Myklebust, Trond wrote:

> On Fri, 2012-06-01 at 11:38 -0400, Chuck Lever wrote:
>> 
>> @@ -1740,9 +1748,19 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
>> 
>> 	if (state->flags & flags) {
>> 		status = nfs41_test_stateid(server, stateid);
>> -		if (status != NFS_OK) {
>> +		switch (status) {
>> +		case NFS_OK:
>> +			/* server recognizes this one, don't re-open */
>> +			break;
>> +		case -NFS4ERR_ADMIN_REVOKED:
>> +		case -NFS4ERR_DELEG_REVOKED:
>> +			/* state was revoked, free then re-open */
>> 			nfs41_free_stateid(server, stateid);
>> 			state->flags &= ~flags;
>> +			break;
>> +		default:
> 
> Please don't add empty "default:" cases. 
> 
>> +			/* anything else: go ahead and re-open it */
>> +			break;
> 
> That last "break" is unnecessary too in standard C99.

OK, all fixed for next version.  I'll wait for additional comments before reposting.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





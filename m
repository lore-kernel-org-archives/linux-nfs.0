From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH 1/2] NFSD: added FREE_STATEID operation
Date: Tue, 31 May 2011 10:52:09 -0400
Message-ID: <4DE50099.6090901@netapp.com>
References: <1305922380-8162-1-git-send-email-bjschuma@netapp.com> <1305922380-8162-2-git-send-email-bjschuma@netapp.com> <4DD6CC12.1020705@netapp.com> <20110525150510.GB11166@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43218 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755277Ab1EaOwL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2011 10:52:11 -0400
In-Reply-To: <20110525150510.GB11166@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/25/2011 11:05 AM, J. Bruce Fields wrote:
> On Fri, May 20, 2011 at 04:16:18PM -0400, Bryan Schumaker wrote:
>> On 05/20/2011 04:12 PM, bjschuma@netapp.com wrote:
>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>> +static __be32
>>> +nfsd4_free_delegation_stateid(stateid_t *stateid)
>>> +{
>>> +	struct nfs4_delegation *dp = search_for_delegation(stateid);
>>> +	if (dp)
>>> +		return nfserr_locks_held;
>>> +	return nfserr_bad_stateid;
>>> +}
>>> +
>>> +static __be32
>>> +nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stateid *stp)
>>> +{
>>> +	if (check_for_locks(stp->st_file, stp->st_stateowner))
>>
>> I'm not sure if stateids are unique to (file, stateowner), but I'm not sure how else to check for locks at the moment.
> 
> Actually, looking... there's a one-to-one lockowner<->lockstateid
> correspondance.  Which is dumb.
> 
> The server's handling of lock state needs more serious help than I
> realized!
> 
> I think your patch is OK now, though.

Thanks for the reviews!

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:45861 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab1HIRji (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Aug 2011 13:39:38 -0400
Message-ID: <4E4170B8.7090409@panasas.com>
Date: Tue, 9 Aug 2011 10:39:04 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        <linux-nfs@vger.kernel.org>, <linux-ext4@vger.kernel.org>,
        <hch@infradead.org>, <yong.fan@whamcloud.com>,
        <linux-fsdevel@vger.kernel.org>, <tytso@mit.edu>,
        <adilger@whamcloud.com>
Subject: Re: [PATCH 3/4] RFC: Remove check for a 32-bit cookie in nfsd4_readdir()
References: <20110808153432.1872437.85783.stgit@fsdevel3> <20110808153808.1872437.85162.stgit@fsdevel3> <20110809173145.GA16206@fieldses.org>
In-Reply-To: <20110809173145.GA16206@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/09/2011 10:31 AM, J. Bruce Fields wrote:
> On Mon, Aug 08, 2011 at 05:38:08PM +0200, Bernd Schubert wrote:
>> Fan Yong <yong.fan@whamcloud.com> noticed setting
>> FMODE_32bithash wouldn't work with nfsd v4, as
>> nfsd4_readdir() checks for 32 bit cookies. However, according to RFC 3530
>> cookies have a 64 bit type and cookies are also defined as u64 in
>> 'struct nfsd4_readdir'. So remove the test for >32-bit values.
> 
> Wow, thanks, I wonder where that check came from.  Looks like it was
> there since the very first nfsv4 commit.
> 

Even for the "very first nfsv4 commit" it sounds like a stupid bug.
Probably a copy/paste from V2 code. What about V3, does V3 code have
this bug?

Boaz

> Applying.
> 
> --b.
> 
>>
>> Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
>> ---
>>  fs/nfsd/nfs4proc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index e807776..9bf0a66 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -691,7 +691,7 @@ nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	readdir->rd_bmval[1] &= nfsd_suppattrs1(cstate->minorversion);
>>  	readdir->rd_bmval[2] &= nfsd_suppattrs2(cstate->minorversion);
>>  
>> -	if ((cookie > ~(u32)0) || (cookie == 1) || (cookie == 2) ||
>> +	if ((cookie == 1) || (cookie == 2) ||
>>  	    (cookie == 0 && memcmp(readdir->rd_verf.data, zeroverf.data, NFS4_VERIFIER_SIZE)))
>>  		return nfserr_bad_cookie;
>>  
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


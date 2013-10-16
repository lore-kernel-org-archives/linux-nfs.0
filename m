Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:63353 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760162Ab3JPIpc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 04:45:32 -0400
Received: by mail-wi0-f169.google.com with SMTP id cb5so6650419wib.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Oct 2013 01:45:31 -0700 (PDT)
Message-ID: <525E5228.80200@primarydata.com>
Date: Wed, 16 Oct 2013 11:45:28 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>, bfields@redhat.com
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: nfs4_file usage
References: <20131015211445.GA23636@infradead.org> <525E2C5C.4020104@primarydata.com> <20131016064649.GB28758@infradead.org>
In-Reply-To: <20131016064649.GB28758@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[adding linux-nfs to the Cc]

On 2013-10-16 09:46, Christoph Hellwig wrote:
> On Wed, Oct 16, 2013 at 09:04:12AM +0300, Benny Halevy wrote:
>> On 2013-10-16 00:14, Christoph Hellwig wrote:
>>> it seems like the pnfs tree uses struct nfs4_file for something entirely
>>> different than the current nfsd usage of it - in fact none of the actual
>>> fields except for the refcount, hashing and inode reference seems to be
>>> shared.
>>
>> The dlm patchset adds these members:
>> +	struct list_head	fi_lo_states;
>>
>> The fi_lo_states (coupled with nfs4_client.cl_lo_states) use case is equivalent
>> to fi_delegations.
>> But that said, it might make sense to move the respective layout state handling
>> to nfs4state.c.
>>
>> +	struct nfs4_fsid	fi_fsid;
>> fi_fsid is a shorthand for fh_export->ex_fsid and it would be expensive to look
>> it up on demand (return and recall by fsid)
>>
>> Other uses in the full pnfsd patchset add:
>> +	struct mutex		fi_lo_lock;
>> for inter-locking layout changing ops (layout get/commit/return) across
>> down calls to the file system.
>> I need to see if that can/should be moved to the layout state structure instead.
>>
>> +	u32			fi_fhlen;
>> +	u8			fi_fhval[NFS4_FHSIZE];
>>
>> Similar to fi_fsid, a shorthand for layout recall by file (common case).
>> I don't see a better place to put it.
> 
> Maybe I wasn't clear enough in the first mail.   pnfs still needs a
> structure the shadows struct inode with all the fields it adds.  I just
> don't think overlyaing it over nfs4_file makes sense, but rather have
> something separate ala:
> 
> struct pnfsd_inode {
> 	atomic_t                pi_ref;
> 	struct hlist_node       pi_hash;
> 	struct list_head        pi_lo_states;

I'm reluctant about the layout stateids as it uses common hashing data structs
locking infrastructure, and code with all other nfsd4 stateids.

I hope that the pnfs layer can just carry a pointer to the nfs4_file
to passed to functions living in nfs4state.c that control the layout state.

> 	struct mutex            pi_lo_lock;
> 	struct nfs4_fsid        pi_fsid;
> 	u32                     pi_fhlen;
> 	u8			pi_fhval[NFS4_FHSIZE];
> };
> 

We can have a similar hash table for pnfsd_inode similar to nfs4_file
Note that nfs4_file is also per inode, not per file as might be reflected from its name.
Maybe moving it nfs4state.c also warrants renaming it to something more accurate.
And while there, change file_hashval to hash on i_ino rather than the inode ptr.

Benny

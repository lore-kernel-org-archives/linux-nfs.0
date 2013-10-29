Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26355 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823Ab3J2NXU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:23:20 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dr Fields James Bruce <bfields@fieldses.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Date: Tue, 29 Oct 2013 13:23:19 +0000
Message-ID: <C034E301-5FCB-4CD1-B01B-1BE5AF6087C0@netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131028214030.GO31322@fieldses.org> <526FAF30.3060502@netapp.com>
 <20131029130649.GA29606@fieldses.org>
In-Reply-To: <20131029130649.GA29606@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 9:06 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, Oct 29, 2013 at 08:50:56AM -0400, Anna Schumaker wrote:
>> On Mon 28 Oct 2013 05:40:30 PM EDT, J. Bruce Fields wrote:
>>> On Mon, Oct 28, 2013 at 10:57:25AM -0400, Anna Schumaker wrote:
>>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>>> index 419572f..3210c6f 100644
>>>> --- a/fs/nfsd/nfs4proc.c
>>>> +++ b/fs/nfsd/nfs4proc.c
>>>> @@ -1028,6 +1028,42 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>> 	return status;
>>>> }
>>>> 
>>>> +static __be32
>>>> +nfsd4_write_plus_hole(struct file *file, struct nfsd4_write_plus *writeplus,
>>>> +		      struct net *net)
>>>> +{
>>>> +	__be32 status;
>>>> +
>>>> +	status = nfsd4_vfs_fallocate(file, writeplus->wp_allocated,
>>>> +				writeplus->wp_offset, writeplus->wp_length);
>>>> +	if (status == nfs_ok) {
>>>> +		writeplus->wp_res.wr_stid = NULL;
>>>> +		writeplus->wp_res.wr_bytes_written = writeplus->wp_length;
>>>> +		writeplus->wp_res.wr_stable_how = NFS_FILE_SYNC;
>>> 
>>> Do we need to sync?
>> 
>> I did the sync in nfsd4_vfs_fallocate (below), but I can move it if 
>> that would make more sense.
> 
> What I meant was--why are we doing a sync at all, instead of returning
> NFS_UNSTABLE and making the client commit?

What if the client specifies FILE_SYNC? The spec doesn't allow the server to return UNSTABLE in that situation.

Trond
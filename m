From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
Date: Sat, 28 Mar 2009 21:32:07 +0300
Message-ID: <49CE6D27.8020601@panasas.com>
References: <49CC40E5.2080506@panasas.com> <20090328011713.GA26402@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12066 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753912AbZC1ScR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 14:32:17 -0400
In-Reply-To: <20090328011713.GA26402@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 28, 2009, 4:17 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, Mar 27, 2009 at 05:58:45AM +0300, Benny Halevy wrote:
>> Hi Bruce,
>>
>> Here's the latest server patches implementing the NFSv4.1
>> Sessions features.
>>
>> This patchset is based over your for-2.6.30 branch
>> and is also available from
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
> 
> I ran the v4.0 pynfs on that branch and got some new failures:
> 
> ACC3     st_access.testNoFh                                       : FAILURE
>            value=10064 not in enum nfsstat4
> CLOSE7   st_close.testNoCfh                                       : FAILURE
>            value=10064 not in enum nfsstat4
> CMT3     st_commit.testNoFh                                       : FAILURE
>            value=10064 not in enum nfsstat4
> CR8      st_create.testNoFh                                       : FAILURE
>            value=10064 not in enum nfsstat4
> 
> Looks like NFS4ERR_SEQUENCE_POS is leaking out to nfsv4 code for some
> reason?

Right, we checked ALLOWED_AS_FIRST_OP for minorversion 0 too.

> 
> (Some similar results omitted.)
> 
> Also there's a bunch of stuff like this:
> 
> NVF1a    st_nverify.testMandLink                                  : FAILURE
>            NVerifying mandatory attributes against getattr should
>            return NFS4ERR_SAME, instead got NFS4_OK
> NVF1d    st_nverify.testMandDir                                   : FAILURE
>            NVerifying mandatory attributes against getattr should
>            return NFS4ERR_SAME, instead got NFS4_OK
> 
> Probably the expansion of the attribute bitmask is exposing some
> preexisting bug in the 4.0 code, but let's try to figure out how to fix
> that.

A change to nfsd4_encode_fattr to encode bitmaps of variable length
(rather than 2) broke _nfsd4_verify.

> 
> I haven't investigated either of these any closer yet.
> 
> --b.

The following two patches fix these regressions:
[PATCH 1/2] SQUASHME: nfsd41: do not verify nfserr_sequence_pos for minorversion 0
[PATCH 2/2] nfsd: dynamically skip encoded fattr bitmap in _nfsd4_verify

Benny

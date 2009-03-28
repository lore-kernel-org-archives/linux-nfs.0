From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
Date: Fri, 27 Mar 2009 21:17:13 -0400
Message-ID: <20090328011713.GA26402@fieldses.org>
References: <49CC40E5.2080506@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37198 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbZC1BRR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2009 21:17:17 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2009 at 05:58:45AM +0300, Benny Halevy wrote:
> Hi Bruce,
> 
> Here's the latest server patches implementing the NFSv4.1
> Sessions features.
> 
> This patchset is based over your for-2.6.30 branch
> and is also available from
> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30

I ran the v4.0 pynfs on that branch and got some new failures:

ACC3     st_access.testNoFh                                       : FAILURE
           value=10064 not in enum nfsstat4
CLOSE7   st_close.testNoCfh                                       : FAILURE
           value=10064 not in enum nfsstat4
CMT3     st_commit.testNoFh                                       : FAILURE
           value=10064 not in enum nfsstat4
CR8      st_create.testNoFh                                       : FAILURE
           value=10064 not in enum nfsstat4

Looks like NFS4ERR_SEQUENCE_POS is leaking out to nfsv4 code for some
reason?

(Some similar results omitted.)

Also there's a bunch of stuff like this:

NVF1a    st_nverify.testMandLink                                  : FAILURE
           NVerifying mandatory attributes against getattr should
           return NFS4ERR_SAME, instead got NFS4_OK
NVF1d    st_nverify.testMandDir                                   : FAILURE
           NVerifying mandatory attributes against getattr should
           return NFS4ERR_SAME, instead got NFS4_OK

Probably the expansion of the attribute bitmask is exposing some
preexisting bug in the 4.0 code, but let's try to figure out how to fix
that.

I haven't investigated either of these any closer yet.

--b.

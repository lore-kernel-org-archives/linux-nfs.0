From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH v2 09/12] nfsd41: Backchannel: cb_sequence	callback
Date: Mon, 14 Sep 2009 10:21:14 +0300
Message-ID: <4AADEEEA.3050400@panasas.com>
References: <4AA8C597.8080809@panasas.com>	<1252574811-30314-1-git-send-email-bhalevy@panasas.com> <20090913202718.GC13109@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:12752 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750891AbZINHVr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2009 03:21:47 -0400
In-Reply-To: <20090913202718.GC13109@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/13/2009 11:27 PM, J. Bruce Fields wrote:
> On Thu, Sep 10, 2009 at 12:26:51PM +0300, Benny Halevy wrote:
>> Implement the cb_sequence callback conforming to draft-ietf-nfsv4-minorversion1
>>
>> Note: highest slot id and target highest slot id do not have to be 0
>> as was previously implemented.  They can be greater than what the
>> nfs server sent if the client supports a larger slot table on the
>> backchannel.  At this point we just ignore that.
> 
> Minor point (applying as is), but, in future: a changelog that says how
> this version of the patch differs from a previous version won't be
> useful to someone reading the git history (and lacking the previous
> versions).  If you think the above mistake is one that someone might
> risk making again, a comment in the appropriate spot in the code might
> be more useful.
> 
> --b.
> 

I disagree. The paragraph above is perfectly understandable if you just
remove the "as was previously implemented". There is no missing information.
Then if so, the "as was previously implemented" is useful extra information
that says that "we tried that before and it was bad". This is the kind of
information that is important to a reader, even without reading the old version.

Just my $0.017

Boaz

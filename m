Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:22929 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315AbbJZMTg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2015 08:19:36 -0400
Subject: Re: [PATCH v7 5/4] copy_file_range.2: New page documenting
 copy_file_range()
To: Christoph Hellwig <hch@infradead.org>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445628736-13058-6-git-send-email-Anna.Schumaker@Netapp.com>
 <562B734D.50800@draigBrady.com> <20151026033925.GA9945@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <562E1A55.4050409@draigBrady.com>
Date: Mon, 26 Oct 2015 12:19:33 +0000
MIME-Version: 1.0
In-Reply-To: <20151026033925.GA9945@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26/10/15 03:39, Christoph Hellwig wrote:
> On Sat, Oct 24, 2015 at 01:02:21PM +0100, P??draig Brady wrote:
>> I'm a bit worried about the sparse expansion and default reflinking
>> which might preclude cp(1) from using this call in most cases, but I will
>> test and try to use it. coreutils has heuristics for determining if files
>> are remote, which we might use to restrict to that use case.
> 
> Can you explain why reflinking and hole expansion are an issue if done
> locally and not if done remotely?  I'd really like to make the call as
> usable as possible for everyone, but we really need clear sem�ntics for
> that.

Fair point on local vs remote. I was just assuming that remote
copy offload would not do reflinking on the backend, or at
least wasn't an exposed option over the remote interface.

I get the impression that you think reflinking should be hidden
from the user, i.e. cp(1) should not have had the --reflink option
(for the last 6 years)?  I'm not convinced of that, and even so
I think lower level interfaces would benefit from finer grained options.
This would be especially useful since there is no general interface
to reflink at present. I was happy with the reflink control options,
thinking the extra control could allow cp to use this by default.

> Also note that Annas current series allows for hole filling - any decent
> implementation should not do them, but that's really a quality of
> implementation and not an interface issue.

I think you're saying the default `cp --sparse=auto` operation
could rely on copy_file_range(...complete file...), while
cp --sparse={always,never} would have to iterate over the
file, punching or filling holes as appropriate. I thought
Anna indicated differently wrt splice filling holes by default.

TBH I'm not clear on the semantics of the current implementation,
so need to test the above in various cases.

thanks,
Pádraig.

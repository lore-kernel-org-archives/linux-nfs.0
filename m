Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40191 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778Ab3LJOoa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 09:44:30 -0500
Message-ID: <52A728A7.8020905@oracle.com>
Date: Tue, 10 Dec 2013 18:43:51 +0400
From: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@infradead.org>,
        Vasily Isaenko <vasily.isaenko@oracle.com>, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com, "Sachin S. Prabhu" <sprabhu@redhat.com>
Subject: Re: nfs vs xfstests 193
References: <20131106115648.GA24804@infradead.org> <52A1CF22.106@oracle.com> <20131206180858.GA2803@infradead.org> <20131206204404.GA12613@fieldses.org> <20131206204747.GB12613@fieldses.org>
In-Reply-To: <20131206204747.GB12613@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/07/2013 12:47 AM, J. Bruce Fields wrote:
> On Fri, Dec 06, 2013 at 03:44:04PM -0500, bfields wrote:
>> On Fri, Dec 06, 2013 at 10:08:58AM -0800, Christoph Hellwig wrote:
>>> On Fri, Dec 06, 2013 at 05:20:34PM +0400, Stanislav Kholmanskikh wrote:
>>>> Just to make the behaviour more consistent between NFS and other
>>>> "local" file systems as It was done by
>>>> commit https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=0953e620de0538cbd081f1b45126f6098112a598
>>>
>>> Seems like we got others in line with XFS behavior.
>>
>> But, not having tested the behavior, it looks like fs/open.c has a
>> simlar !S_ISDIR() check.  Where's that behavior implemented?
>>
>>> I'd prefer to have NFS follow this as well.
>>
>> Huh.  Sachin, do you remember if there was any other motivation behind
>> that patch?
>
> Never mind, I see, the complaint is about the case where the id's don't
> change, not about the directory case.  So Sachin's
> 0953e620de0538cbd081f1b45126f6098112a598 doesn't actually have anything
> to do with this.
>
> I'm fine with removing the id comparisons and changing the nfsd behavior
> to match local filesystems.

Great.

I will try to produce a patch for this.

>
> --b.
>
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs
>

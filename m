From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 13:11:02 -0400
Message-ID: <9CE7224B-002F-48B8-9DCB-8776A61167EF@oracle.com>
References: <20080425080535.GA4999@uio.no> <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com> <20080425163457.GA6952@uio.no> <F4C3F5C0-1D60-4285-9CB3-171C70C96B03@oracle.com> <20080425165921.GA7108@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49898 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763693AbYDYRTU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 13:19:20 -0400
In-Reply-To: <20080425165921.GA7108-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 12:59 PM, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 12:45:36PM -0400, Chuck Lever wrote:
>>> fugl:~# mount -t nfs -v -o retry=0 10.0.0.11:/foo /mnt
>>> mount.nfs: timeout set for Thu Jan  1 14:40:25 1970
>>> mount.nfs: text-based options: 'retry=0,addr=10.0.0.11'
>> On my test system (Fedora 7) I get correct behavior with both /bin/ 
>> mount
>> and when using /sbin/mount.nfs directly.
>
> It seems the patch has an issue:
>
> +       if (!parse_retry_option(&timeout, options,  
> NFS_DEF_FG_TIMEOUT_MINUTES))
>
> where parse_retry_option() _adds_ to timeout. But timeout is not  
> initialized :-)

Just change "*timeout +=" to "*timeout =" in parse_retry_option().

That was the bug I was trying to fix in the first place.  Sigh.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

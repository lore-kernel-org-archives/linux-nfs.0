From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 12:45:36 -0400
Message-ID: <F4C3F5C0-1D60-4285-9CB3-171C70C96B03@oracle.com>
References: <20080425080535.GA4999@uio.no> <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com> <20080425163457.GA6952@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:35496 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763048AbYDYQsV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 12:48:21 -0400
In-Reply-To: <20080425163457.GA6952-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 12:34 PM, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 12:20:19PM -0400, Chuck Lever wrote:
>>> It seems retry= is now additive with the text-based mount  
>>> interface.  In
>>> particular, "mount -o retry=0" still gives a two-minute timeout.  
>>> Is  this
>>> intentional?
>> No, it's broken.  Can you test the attached patch?
>
> It seems it creates rather odd behavior:
>
>
> fugl:~# mount -t nfs -v -o retry=0 10.0.0.11:/foo /mnt
> mount.nfs: timeout set for Thu Jan  1 14:40:25 1970
> mount.nfs: text-based options: 'retry=0,addr=10.0.0.11'

On my test system (Fedora 7) I get correct behavior with both /bin/ 
mount and when using /sbin/mount.nfs directly.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

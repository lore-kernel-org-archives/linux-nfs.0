From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/10] RFC: NFS-related fs/Kconfig updates
Date: Tue, 5 Feb 2008 15:41:38 -0500
Message-ID: <68C5871E-9118-4E45-B206-FA5A4ECBEE2D@oracle.com>
References: <20080205180726.32229.35186.stgit@manray.1015granger.net> <20080205203033.GK8210@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42758 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759006AbYBEUmu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 15:42:50 -0500
In-Reply-To: <20080205203033.GK8210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 5, 2008, at 3:30 PM, J. Bruce Fields wrote:
> On Tue, Feb 05, 2008 at 01:08:28PM -0500, Chuck Lever wrote:
>> Another pass at cleaning up the NFS and NFSD entries in fs/Kconfig.
>>
>> Comments / suggestions?
>
> "Another pass" isn't clearly a "please apply if there are no
> objections", so I assume you're not done?

"RFC:" in the Subject: means that this is only a "request for comments".

When the patch set is ready, I will send it To: you and/or Trond  
instead of To: the mailing list, and finish the cover letter with  
"Please apply".

> The help text changes and the change to remove the "ifdef TCP"'s at
> least look fine to me.

Thanks.  I am also trying to find a way to get the kbuild folks to  
have a look at this.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

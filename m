From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#476577: corrected patch
Date: Mon, 21 Apr 2008 14:04:18 -0400
Message-ID: <A10E2E89-C45F-46DC-8718-157F25B8061D@oracle.com>
References: <20080417200928.GA20809@kodama.kitenet.net> <20080420223416.GA12722@uio.no> <40FD052D-BBC2-4AE4-BEF3-56914D39E13A@oracle.com> <20080421165314.GA2178@kodama.kitenet.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Steinar H. Gunderson" <sesse@debian.org>,
	linux-nfs@vger.kernel.org, 476577@bugs.debian.org
To: Joey Hess <joeyh@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:30555 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbYDUSFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 14:05:46 -0400
In-Reply-To: <20080421165314.GA2178-goE9YToxfH7EOVZ/abRnzaxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Joey-

On Apr 21, 2008, at 12:53 PM, Joey Hess wrote:
> Chuck Lever wrote:
>> What if /etc/mtab is a symlink to a valid writable file that is not /
>> proc/mounts?  The test you introduce below will prevent that case  
>> from
>> working properly.
>
> Note that util-linux mount does the same thing in this case, so this  
> must be an uncommon case.
>
> umount.nfs also avoids writing to /etc/mtab if it is a symlink..

In that case, I think the patch description should start out with  
"Make mount.nfs handle symlinked /etc/mtab the way umount.nfs and util- 
linux handle it."  Then the description should explain why this  
important.

That provides much better documentation of the change and why it is  
needed.  Having the util-linux precedent is especially good to know,  
and demonstrates that the right homework was done.

>> Is there a security issue with creating a file in / when /proc isn't
>> mounted, or is this just an inconvenience?
>
> The worse problem is that mount.nfs fails with a nonzero exit code if
> /proc/ is mounted, since the fchmod of /proc/mounts fails.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

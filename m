From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Kernel call trace on NFS-mount (using autofs).
Date: Wed, 21 May 2008 12:53:41 -0400
Message-ID: <99E11D43-3D89-4C30-8026-955B1D01E557@oracle.com>
References: <48331EAE.6060107@krogh.cc> <3C99F710-A573-4932-8F37-BE784BD66581@oracle.com> <4833AD1B.6010408@krogh.cc>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58228 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755816AbYEUQ5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 12:57:05 -0400
In-Reply-To: <4833AD1B.6010408-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 21, 2008, at 1:03 AM, Jesper Krogh wrote:
> Chuck Lever wrote:
>>> Kernel is a: 2.6.22-14-generic. I wasn't able to search similar  
>>> stuff
>>> up from the archive.
>> It would be interesting to know which nfs-utils version you have  
>> installed, too.
>
> It is: 1.1.1~git-20070709-3ubuntu1

In that case different code paths in the mount.nfs command may be  
exercised when you upgrade to 2.6.25.

I think 2.6.22 would force the mount.nfs command to use the legacy  
binary mount API, whereas 2.6.25 would allow it to use the new text  
API.  This might make a difference if the mount.nfs command is somehow  
constructing a data structure in user space that 2.6.22's VFS layer  
chokes on.

Idle speculation, of course.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

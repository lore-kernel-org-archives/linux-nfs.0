From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 28 Apr 2008 17:11:41 -0400
Message-ID: <342EE880-D74F-4652-B354-F2A821C99256@oracle.com>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com> <20080425142712.GA6119@uio.no> <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com> <20080425235546.GA9053@uio.no> <20080425235713.GA9109@uio.no> <D6B17926-F41E-4126-A94D-55B37E696BCC@oracle.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38404 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937375AbYD1VTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 17:19:42 -0400
In-Reply-To: <D6B17926-F41E-4126-A94D-55B37E696BCC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2008, at 11:28 AM, Chuck Lever wrote:
> On Apr 25, 2008, at 7:57 PM, Steinar H. Gunderson wrote:
>> On Sat, Apr 26, 2008 at 01:55:46AM +0200, Steinar H. Gunderson wrote:
>>> I checked the original bug report, and indeed it seems that the  
>>> blocking was
>>> on the client there as well. I'll ask the user to check what  
>>> happens when the
>>> filtering is done server-side instead.
>>
>> Hm, no, there's also reports of blocking on a firewall in the  
>> middle; see
>>
>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=473171
>
> The user is correct that the mount process for NFSv4 should not  
> attempt to use the portmapper unless the port=0 option is  
> specified.  I will look into the problem.


This issue may be addressed as a side-effect of:

commit f22d6d79fe227245363a8849ea8c85fe6c6598c3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:10:22 2008 -0400

     NFS: Save the value of the "port=" mount option

     During a remount based on the mount options displayed in
     /proc/mounts, we want to preserve the original behavior of
     the mount request.  Let's save the original setting of the
     "port=" mount option in the mount's nfs_server structure.


Please give 2.6.25 final a try to see if it prevents the noted  
extraneous rpcbind activity during an NFSv4 mount.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:32143 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab2CBRTJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 12:19:09 -0500
Subject: Re: [PATCH 09/15] NFS: Add a client-side function to display NFS file handles
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4F51009E.6030906@RedHat.com>
Date: Fri, 2 Mar 2012 12:19:02 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <A558B81B-F666-4783-8FC8-7C2929BBBCE8@oracle.com>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>  <20120301220131.2138.63609.stgit@degas.1015granger.net> <1330640881.15828.9.camel@lade.trondhjem.org> <4F51009E.6030906@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 2, 2012, at 12:17 PM, Steve Dickson wrote:

> 
> 
> On 03/01/2012 05:28 PM, Myklebust, Trond wrote:
>> On Thu, 2012-03-01 at 17:01 -0500, Chuck Lever wrote:
>>> For debugging, introduce a simplistic function to print NFS file
>>> handles on the system console.  The main function is hooked into the
>>> dprintk debugging facility, but you can directly call the helper,
>>> _nfs_display_fhandle(), if you want to print a handle unconditionally.
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> 
>> 
>> One of the things that I really like about wireshark is that it also
>> displays a 32-bit hexadecimal hash of the filehandle. That allows you to
>> compare 2 filehandles _much_ faster than trying to look at the full
>> shebang.
>> 
>> 
> +1 Being able to easily trace filehandle in both the kernel debug and
> wireshark would be huge.... IMHO...

Dros mentioned a possible follow-on patch last night at the pub that would add exactly this functionality.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





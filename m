Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756326Ab2CBRRT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 12:17:19 -0500
Message-ID: <4F51009E.6030906@RedHat.com>
Date: Fri, 02 Mar 2012 12:17:18 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/15] NFS: Add a client-side function to display NFS
 file handles
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>  <20120301220131.2138.63609.stgit@degas.1015granger.net> <1330640881.15828.9.camel@lade.trondhjem.org>
In-Reply-To: <1330640881.15828.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/01/2012 05:28 PM, Myklebust, Trond wrote:
> On Thu, 2012-03-01 at 17:01 -0500, Chuck Lever wrote:
>> For debugging, introduce a simplistic function to print NFS file
>> handles on the system console.  The main function is hooked into the
>> dprintk debugging facility, but you can directly call the helper,
>> _nfs_display_fhandle(), if you want to print a handle unconditionally.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
> 
> One of the things that I really like about wireshark is that it also
> displays a 32-bit hexadecimal hash of the filehandle. That allows you to
> compare 2 filehandles _much_ faster than trying to look at the full
> shebang.
> 
> 
+1 Being able to easily trace filehandle in both the kernel debug and
wireshark would be huge.... IMHO... 

steved. 

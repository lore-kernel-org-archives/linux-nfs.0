Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:19937 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999Ab2CAWck (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:32:40 -0500
Subject: Re: [PATCH 09/15] NFS: Add a client-side function to display NFS file handles
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1330640881.15828.9.camel@lade.trondhjem.org>
Date: Thu, 1 Mar 2012 17:32:35 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <C63AE7A1-D21E-4222-9927-60D7B092CD58@oracle.com>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net> <20120301220131.2138.63609.stgit@degas.1015granger.net> <1330640881.15828.9.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 1, 2012, at 5:28 PM, Myklebust, Trond wrote:

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

It should be easy to add a displayed hash in a subsequent patch.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





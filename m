Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:38665 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab1KCVQz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 17:16:55 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111103211100.GA8393@umich.edu>
Date: Thu, 3 Nov 2011 17:16:42 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu>
To: Jim Rees <rees@umich.edu>, Lukas Razik <linux@razik.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 3, 2011, at 5:11 PM, Jim Rees wrote:

> Trond Myklebust wrote:
> 
>> [ 442.666622] NFS: failed to create MNT RPC client, status=-60
>> [ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
>> [ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
>> [ 442.667032] VFS: Insert root floppy and press ENTER
>> 
>  Error 60 is ETIMEDOUT on SPARC, so it seems that the problem is
>  basically the same one that you see in your 2.6.32 trace (rpcbind:
>  server 137.226.167.241 not responding, timed out) except that now it is
>  a fatal error.
> 
>  Any idea why the first RPC calls might be failing here? A switch
>  misconfiguration or something like that perhaps?
> 
> Wasn't there a change in the way nfs mount options are handled by the kernel
> for nfsroot about the time of 2.6.39?  Something about changing from default
> udp to tcp maybe?

There was a change, but it was changed back to UDP because of problems like this.  Behavior in 3.0 or the latest 2.6.39 stable kernel may be improved.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





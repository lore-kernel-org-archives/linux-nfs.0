From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/5] NFS: set transport defaults after mount option parsing is finished
Date: Thu, 12 Jun 2008 15:34:59 -0400
Message-ID: <C029305A-09ED-4D57-997D-484D8C42CD3D@oracle.com>
References: <20080612163416.13197.92911.stgit@manray.1015granger.net> <20080612163756.13197.37893.stgit@manray.1015granger.net> <1213289857.14478.10.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35522 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386AbYFLTfX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 15:35:23 -0400
In-Reply-To: <1213289857.14478.10.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 12, 2008, at 12:57 PM, Trond Myklebust wrote:
> On Thu, 2008-06-12 at 12:37 -0400, Chuck Lever wrote:
>> Address some unfortunate mount option parsing behavior by setting  
>> certain
>> transport-based defaults *after* option parsing is complete.
>>
>> o  Some options don't obey the "rightmost wins" rule.  Jeff Layton
>>    noticed that specifying the "proto=" mount option after the  
>> "retrans"
>>    or "timeo" options will cause the retrans and timeo values to be
>>    overwritten with default settings.
>>
>>    Allow these options to be specified in any order without  
>> unexpectedly
>>    reverting retrans and timeo to their default.
>>
>> o  I've received several reports that text-based mounting through
>>    firewalls that block UDP fails, even if "proto=tcp" is specified.
>>
>>    If a user specifies "proto=tcp" via the legacy mount API, the  
>> mount
>>    command also uses TCP to contact the server's mount daemon.  Ditto
>>    for "proto=udp".  We want the kernel's mount option to emulate  
>> this
>>    behavior; however, we still want the default mount protocol to  
>> be UDP
>>    if no transport options were specified.
>
> Why is it necessary to set these defaults in nfs_parse_mount_options?
> This is quite unrelated to parsing of the mount string.

The default transport timer settings are the same for both NFS and  
NFSv4, so I thought it would be best to put a single copy of that  
logic in a common code path.

I suppose we could just factor it into a helper and have both the NFS  
and NFSv4 mount paths call this, but I'm not sure what the value of  
that would be.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

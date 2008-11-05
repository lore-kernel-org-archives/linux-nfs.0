From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 8/8] NLM: allow lockd requests from an unprivileged port
Date: Wed, 5 Nov 2008 16:25:17 -0500
Message-ID: <70C4B893-100A-4047-8038-C401DA44B439@oracle.com>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net> <20081105202542.14469.35584.stgit@ingres.1015granger.net> <1225917994.16857.42.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55263 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbYKEVZb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:25:31 -0500
In-Reply-To: <1225917994.16857.42.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 5, 2008, at 3:46 PM, Trond Myklebust wrote:
> On Wed, 2008-11-05 at 15:25 -0500, Chuck Lever wrote:
>> If the admin has specified the "noresvport" option for an NFS mount
>> point, the kernel's NFS client uses an unprivileged source port for
>> the main NFS transport.  The kernel's lockd client should use an
>> unprivileged port in this case as well.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>
> error: patch failed: fs/lockd/host.c:44
> error: fs/lockd/host.c: patch does not apply

I mentioned that in the cover letter.  It's another case where patches  
I've sent to you depend on patches that Bruce is taking.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

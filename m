From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/6] nfsd: add support for NFSv4 callbacks over IPv6
	(try #5)
Date: Fri, 21 Aug 2009 11:44:04 -0400
Message-ID: <20090821154404.GD18318@fieldses.org>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com> <D24FC53A-3E15-444F-BCDF-BE8454205B4F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48993 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932435AbZHUPoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 11:44:07 -0400
In-Reply-To: <D24FC53A-3E15-444F-BCDF-BE8454205B4F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 14, 2009 at 02:05:03PM -0400, Chuck Lever wrote:
> On Aug 14, 2009, at 12:57 PM, Jeff Layton wrote:
>> Fifth attempt at a patchset to add support for NFSv4 callbacks over
>> IPv6. Changes from last patchset are mostly to address Chuck's  
>> comments:
>>
>> 1) made the new address comparison and copy routines into static  
>> inlines
>> and added them to clnt.h. Ditto for the get_scope_id function.
>>
>> 2) combined the patch to change nfs4_cb_conn to hold address in
>> sockaddr_storage with the one to convert gen_callback to use
>> rpc_uaddr2sockaddr. That eliminates changes to the parse_ipv4 function
>> that eventually gets ripped out.
>>
>> Tested using opensolaris and linux and verifying that delegations  
>> could
>> be properly recalled. I also tested mounts to the server's link-local
>> address and verified that the callback channel connected correctly.
>
> Looks good.
>
> Acked-by: Chuck Lever <chuck.lever@oracle.com>

Applied, thanks to you both.

--b.

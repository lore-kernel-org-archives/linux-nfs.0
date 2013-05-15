Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41305 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182Ab3EOT2g convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 15:28:36 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130515174806.GO16811@fieldses.org>
Date: Wed, 15 May 2013 15:28:27 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <0B08EFEB-D651-4A68-8F1F-2078F62B6A5A@oracle.com>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net> <20130513162528.1942.64673.stgit@seurat.1015granger.net> <20130515160424.GK16811@fieldses.org> <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com> <20130515171601.GL16811@fieldses.org> <20130515173916.GM16811@fieldses.org> <D8763141-7185-499B-ADFA-659F9992269C@oracle.com> <20130515174806.GO16811@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 15, 2013, at 1:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Wed, May 15, 2013 at 01:42:58PM -0400, Chuck Lever wrote:
>> 
>> On May 15, 2013, at 1:39 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> 
>>> By the way, have you looked at SP4_MACH_CRED at all yet?  It's a
>>> selfish question (I could use something to test against), but I
>>> think it's also what you want if you want krb5i-protected 4.1 state.
>> 
>> I asked about that recently and was told SP4_MACH_CRED was going the
>> way of the do do
> 
> Do you remember who said that?  Is the discussion on line somewhere?

No, I mis-remembered.  I was thinking of SP4_SSV.

> 
>> (or did I misunderstand the response from the floor?).
>> 
>> I'm certainly open to exploring other solutions, but I do want to be
>> practical about it.  Will it be supported on other servers besides
>> Linux?  Does SP4_MACH_CRED help for NFSv4.0?
> 
> I haven't tested other servers.  It's a 4.1-only feature.

SP4_MACH_CRED for 4.1 appears useful, but I think we would need to consider:

  o  whether SP4_MACH_CRED is a broadly implemented feature where Linux
     clients can rely on it being there in typical environments

  o  how to address the "no keytab" issue for NFSv4.0, which does not
     have SP4_MACH_CRED (that I am aware of)

Andy is probably more interested in seeing SP4_MACH_CRED implemented in the Linux client, as it is one solution for the "user cred expired while there is still dirty data in the client's page cache" problem, I think.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





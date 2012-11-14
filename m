Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:24676 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab2KNXhk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 18:37:40 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] nfs(5): Document the minorversion= mount option
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0E75@SACEXCMBX04-PRD.hq.netapp.com>
Date: Wed, 14 Nov 2012 18:37:36 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <8CFA849C-DE85-41BB-8EEA-DBC9FF65FB6E@oracle.com>
References: <20121114223600.48062.5680.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0DB4@SACEXCMBX04-PRD.hq.netapp.com> <A7E004BD-A5DA-4258-978A-80E46DBE3D32@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0E75@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 14, 2012, at 6:12 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-11-14 at 18:03 -0500, Chuck Lever wrote:
>> On Nov 14, 2012, at 6:01 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>>> -----Original Message-----
>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>>>> Sent: Wednesday, November 14, 2012 5:39 PM
>>>> To: linux-nfs@vger.kernel.org
>>>> Subject: [PATCH] nfs(5): Document the minorversion= mount option
>>>> 
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> 
>>>> Our pals on the Solaris team recently noticed that the minorversion= option
>>>> is not documented in nfs(5).  This is a first take, just to start the conversation.
>>>> I'm pretty sure I got the kernel version information wrong, for instance.
>>>> 
>>>> Any other comments?
>>> 
>>> You might want to note that it is deprecated in favour of the "vers=4.1" notation, and for that reason we might want to forgo documenting it altogether.
>> 
>> OK.  minorversion= is the only way to get NFSv4.1 on EL6-based distributions, isn't it?
> 
> You didn't seem to be writing a manpage for the RHEL-6 distros: "Before
> kernel 2.6.38, the minor version is always zero...". As far as I know,
> RHEL-6 is still based on 2.6.32...

...for some very loose definition of "based on".  One wonders how to document kernel versions in this instance.  One way to fix this is to have RH patch their copy of nfs(5) privately, while upstream nfs-utils can handle this in some other way.

However, search for "Parallel NFS" on this page:

  https://access.redhat.com/knowledge/docs/en-US/Red_Hat_Enterprise_Linux/6/html-single/6.2_Release_Notes/index.html

This seems to me to count as public documentation of "minorversion=", and suggests that people are likely already using this formal API.  I would hesitate to remove it in this instance.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


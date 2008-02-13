From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Wed, 13 Feb 2008 13:58:54 -0500
Message-ID: <20080213185854.GF13462@fieldses.org>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net> <20080212212325.GM18625@fieldses.org> <9C44C93A-AC87-4B21-8E31-872186ABCEBB@oracle.com> <20080212223020.GO18625@fieldses.org> <47B336CD.2020305@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981AbYBMS71 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2008 13:59:27 -0500
In-Reply-To: <47B336CD.2020305@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2008 at 01:28:29PM -0500, Chuck Lever wrote:
> J. Bruce Fields wrote:
>> On Tue, Feb 12, 2008 at 05:10:57PM -0500, Chuck Lever wrote:
>>> On Feb 12, 2008, at 4:23 PM, J. Bruce Fields wrote:
>>>
>>>> On Mon, Feb 11, 2008 at 05:12:16PM -0500, Chuck Lever wrote:
>>>>> Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
>>>>> ensure that PROC_FS was enabled if NFSD_V4 was enabled.
>>>>>
>>>>> There is a guideline in Documentation/kbuild/kconfig-language.txt 
>>>>>  that
>>>>> states "In general use select only for non-visible symbols (no   
>>>>> prompts
>>>>> anywhere) and for symbols with no dependencies."
>>>>>
>>>>> A quick grep around other Kconfig files reveals that no entry   
>>>>> currently
>>>>> uses "select PROC_FS" -- every one uses "depends on".  Thus   
>>>>> CONFIG_NFSD_V4
>>>>> should use "depends on PROC_FS" as well.
>>>> OK.
>>>>
>>>>> For SUNRPC_GSS, it's a little more complex.  Other entries can   
>>>>> "select"
>>>>> SUNRPC_GSS, as it is non-visible.  However, the guideline suggests an
>>>>> entry can't "select" it if it has a dependency (such as PROC_FS).
>>>>> So, we add forward dependencies on PROC_FS to RPCSEC_GSS_FOO instead.
>>>> This also makes the client dependent on PROC_FS, which it wasn't   
>>>> before.
>>>>
>>>> I assume nobody cares?
>>> Huh?  If I disable PROC_FS, I can still select the NFS client 
>>> options, even NFSv4.
>>
>> OK.  I'm confused, then:
>>
>> 	NFS_V4 selects RPCSEC_GSS_KRB5
>> 	RPCSEC_GSS_KRB5 (after this patch) depends on PROC_FS
>>
>> What am I missing?
>
> It appears that the "select RPCSEC_GSS_KRB5" is a no-op if  
> RPCSEC_GSS_KRB5 hasn't met it's forward dependencies.

Oh, OK, I didn't understand that.

However, this means that it's no longer possible to build a V4 client
with krb5 support without also including PROC_FS.  So I think we can't
apply this as is.

--b.

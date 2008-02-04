From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss
	server cases
Date: Mon, 4 Feb 2008 18:24:13 -0500
Message-ID: <20080204232413.GF32086@fieldses.org>
References: <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org> <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com> <20080128214851.GO16785@fieldses.org> <E9EA25D0-1865-4EC2-BE61-8DA062C43C60@oracle.com> <20080204221521.GH18682@fieldses.org> <2C5597F8-E4D5-4D81-B4CF-83E72B759F53@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kbuild@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:44701 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202AbYBDXYS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2008 18:24:18 -0500
In-Reply-To: <2C5597F8-E4D5-4D81-B4CF-83E72B759F53@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2008 at 06:17:40PM -0500, Chuck Lever wrote:
> On Feb 4, 2008, at 5:15 PM, J. Bruce Fields wrote:
>> On Mon, Feb 04, 2008 at 04:29:40PM -0500, Chuck Lever wrote:
>>> And, a quick grep around other Kconfig files reveals that no-one else
>>> uses "select PROC_FS" -- every case uses "depends on".  Thus
>>> CONFIG_NFSD_V4 should use "depends on PROC_FS" as well.
>>
>> OK.  Is there a chance you make a patch with a changelog summarizing
>> this?
>
> OK, will post after I've synced up with 2.6.25-rc1 + your server  
> patches.

Thanks!

>>> Since SUNRPC_GSS is already a non-visible config option and is set  
>>> via
>>> "select", it's more difficult to say with certainty how a "depends on
>>> PROC_FS" clause should be constructed for that.  However, MAINTAINERS
>>> suggests that linux-kbuild@vger might be an appropriate place to ask
>>> about these things.
>>
>> OK, so the question is: how can we ensure that PROC_FS is turned on  
>> when
>> SUNRPC_GSS *and* NFSD are (where both SUNRPC_GSS and NFSD may be
>> independently set on or off), while still leaving SUNRPC_GSS a  
>> tristate
>> whose value is at least that of RPCSEC_GSS_KRB5 and RPCSEC_GSS_SPKM3.
>
>
> How about adding "depends on ... && PROC_FS" in the RPCSEC_GSS_FOO  
> sections?
>
> I also thought about adding "depends on PROC_FS" under the SUNRPC_GSS  
> section.

Well, in theory I think it's currently possible to build a kernel with
NFS and SUNRPC_GSS but no PROC_FS (or NFSD).  Such a change would make
that no longer possible.  (Whether anyone cares, I don't know.)

--b.

From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: regression: am-utils stopped working in 2.6.25-rc*
Date: Wed, 02 Apr 2008 10:53:36 +0300
Message-ID: <47F33B80.1070508@panasas.com>
References: <Pine.SOC.4.64.0803281447530.6128@math.ut.ee>	 <20080401210742.GE21343@fieldses.org> <1207088063.13443.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:4164 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751869AbYDBHyH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2008 03:54:07 -0400
In-Reply-To: <1207088063.13443.22.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 02, 2008, 1:14 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2008-04-01 at 17:07 -0400, J. Bruce Fields wrote:
>> On Fri, Mar 28, 2008 at 03:20:18PM +0200, Meelis Roos wrote:
>>> Current 2.6.25-rc* kernels have broken am-utils (NFS-based automounter) 
>>> support. No error messages, just "no such file or directory" when trying 
>>> to enter /net/anotherhostname. Just tried 2.6.24 and that worked fine. 
>>> am-utils is the latest in Debian unstable, 6.1.5-9.
>>>
>>> Earliest 2.6.25-rc currently tested was 2.6.25-rc3+git as of 20080304. 
>>> This version reports 
>>> Invalid hostname "pid3477@koiott:/net" in NFS lock request
>>> into dmesg and am-utils does not work.
>>>
>>> 2.6.25-rc4+git as of 20080310 and later ones do not show this message 
>>> but am-utils does still not work.
>>>
>>> Will try bisecting it further.
>> Have you figured out anything more?  Can strace show exactly which
>> system call is  failing?
> 
> See the bugzilla report:
>   http://bugzilla.kernel.org/show_bug.cgi?id=10349

FWIW, I've already opened this bug on am-utils's bugzilla:
https://bugzilla.am-utils.org/show_bug.cgi?id=612

I updated it with the info on this message.

Benny

> 
> I'm still waiting to hear back from Meelis, but to me this looks like an
> am-utils bug.
> 
> AFAICS, am-utils advertises a binary NFS mount structure version of '6',
> to the mount() syscall, but internally they only initialise the
> equivalent of a version '4' structure.
> When
>      http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=f9c3a3802119a2d30f3e4a69aef30a81e09d0209
> was merged, then this failure to initialise the selinux 'context' field
> causes mount() to return an EINVAL.
> 
> Cheers
>   Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


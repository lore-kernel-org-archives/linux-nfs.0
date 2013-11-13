Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:12631 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626Ab3KMQBT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 11:01:19 -0500
Message-ID: <5283A24D.4010309@netapp.com>
Date: Wed, 13 Nov 2013 11:01:17 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com> <20131112194529.GA26341@fieldses.org> <52828767.3030909@netapp.com> <20131112195911.GA28033@fieldses.org>
In-Reply-To: <20131112195911.GA28033@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2013 02:59 PM, J. Bruce Fields wrote:
> On Tue, Nov 12, 2013 at 02:54:15PM -0500, Anna Schumaker wrote:
>> On 11/12/2013 02:45 PM, J. Bruce Fields wrote:
>>> On Tue, Nov 12, 2013 at 02:04:05PM -0500, Anna Schumaker wrote:
>>>> These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS is
>>>> still under discussion with the IETF after my last series of patches, so I
>>>> am holding off on resubmitting until after spec discussion dies down.
>>>>
>>>> Questions?  Comments?  Thoughts?
>>>> Anna
>>>>
>>>> Anna Schumaker (3):
>>>>   NFSD: Update error codes
>>>
>>> I don't think I got this first patch.
>>
>> It's in the "patches" directory I used, but I don't see it in my gmail inbox either.  I'll send it out in a minute.
>>
>>>
>>>>   NFSD: Create nfs v4.2 decode ops
>>>>   NFSD: Implement SEEK
>>>
>>> I'd like to be reassured the protocol is reasonably stable before we
>>> commit this.  I haven't been following the ietf wg discussion closely.
>>>
>>> And this should initially be disabled by default.  So, probably either:
>>>
>>> 	- Introduce a new NFSD_V4_SEEK option, or
>>> 	- Combine this and NFSD_V4_SECURITY_LABEL and this into a single
>>> 	  NFSD_V4_2 option.
>>>
>>> And recommend "N" for now.
>>>
>>> Probably the latter I guess, to be consistent with the client.  And
>>> because otherwise we could end up with an awful lot of config options.
>>
>> Sure, I can do that easily enough.
> 
> OK.  In that case, you'll probably want to do an additional patch at the
> beginning just to replace NFSD_V4_SECURITY_LABEL by NFSD_V4_2.  Note
> it's not a pure search-and-replace since the latter covers a little more
> code.

Would you accept a patch that instead introduces CONFIG_NFSD_V4_2 and then makes the security label depend on that config option?

> 
> The only thing that worries me a bit is the features may mature at
> different times.  I guess when the time comes we could split it into
> NFSD_V4_2 and NFSD_V4_2_EXPERIMENTAL and recommend distros and
> non-developers turn on only the former?
> 
> --b.
> 


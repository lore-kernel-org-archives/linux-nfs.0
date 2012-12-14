Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42415 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419Ab2LNNhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2012 08:37:21 -0500
Message-ID: <50CB2B87.6070009@suse.com>
Date: Fri, 14 Dec 2012 19:07:11 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] idmapd: allow non-ASCII characters (UTF-8) in NFSv4 domain
 name
References: <50CA0254.4030308@suse.com> <20121213165028.GE24855@fieldses.org>
In-Reply-To: <20121213165028.GE24855@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/13/2012 10:20 PM, J. Bruce Fields wrote:
> On Thu, Dec 13, 2012 at 09:59:08PM +0530, Suresh Jayaraman wrote:
>>
>> The validateascii() check in imconv() maps NFSv4 domain names with non-ASCII
>> characters to 'nobody'. In setups where Active directory or LDAP is used this
>> causes names with UTF-8 characters to be mapped to 'nobody' because of this
>> check.
>>
>> As Bruce Fields puts it:
>>
>> "idmapd doesn't seem like the right place to enforce restrictions on names.
>> Once the system has allowed a name it's too late to be complaining about it
>> here."
>>
>> Remove the check from imconv() and remove the validateascii() function itself
>> as the only user of that function is being removed by this patch.
> 
> Thanks, seem fine.  The only other thing I notice is that
> validateascii() also checks (in a slightly strange way) for null
> termination of the string, and it's the only place in idmapd that does.
> 
> But I think it'd be a kernel bug to pass up a non-terminated string
> here, so skipping that check is fine too.
> 
> Possibly worth a comment, or a check just for null-termination if you
> want to be extra-careful.
> 

You are right. I think being extra-careful is Ok. I'll respin this patch
with a null-termination check.

Thanks

-- 
Suresh Jayaraman

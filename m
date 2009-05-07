From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 2/2] Allow nfs/vers=4 option in text-based mount commands
Date: Thu, 07 May 2009 13:03:08 -0700
Message-ID: <4A033E7C.9060605@disney.com>
References: <1241560004-16787-1-git-send-email-kevin.constantine@disneyanimation.com> <1241560004-16787-2-git-send-email-kevin.constantine@disneyanimation.com> <1241560004-16787-3-git-send-email-kevin.constantine@disneyanimation.com> <6BEE21E5-A57E-46EA-A9A2-AED95715BFDE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:13994 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959AbZEGUDJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2009 16:03:09 -0400
In-Reply-To: <6BEE21E5-A57E-46EA-A9A2-AED95715BFDE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> 
> On May 5, 2009, at 5:46 PM, Kevin Constantine wrote:
> 
>> This allows a user to specify nfsvers=4, or vers=4 on the mount
>> commandline and have mount.nfs4 called as though fstype=nfs4 were
>> specified.  This patch handles the nfsmount_string case in
>> mount.c's try_mount().
>>
>> We get the value of the "vers=" or "nfsvers=" from the nfsmount_info
>> structure, and if the value equals 4, we set the fstype to nfs4, and
>> remove the nfsvers/vers options from the structure since it shouldn't
>> be there in the first place, and we don't want to pass it along down
>> the stack.
>>
>> po_get_numeric returns the rightmost instance, so we honor the last
>> value of nfsvers/vers in the event that it is overridden later in the
>> options string.
>>
>> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
>> ---
>> utils/mount/stropts.c |    9 +++++++++
>> 1 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index c369136..72b0d13 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -754,6 +754,15 @@ static const char *nfs_background_opttbl[] = {
>>
>> static int nfsmount_start(struct nfsmount_info *mi)
>> {
>> +    long tmp;
>> +    po_get_numeric(mi->options, "vers", &tmp);
>> +    po_get_numeric(mi->options, "nfsvers", &tmp);
> 
> If someone specifies both a vers= and a nfsvers= on the command line, 
> this won't handle it.  You need to implement a rightmost search, as 
> Steve's patch (posted previously on this list) did.
> 

I can't seem to find Steve's patches relating to this issue.  I'm 
assuming that since there are already patches related to this, it's not 
worth pursuing these particular patches.

Let me know

-kevin

>> +    if (tmp == 4) {
>> +        mi->type = "nfs4";
>> +        po_remove_all(mi->options, "vers");
>> +        po_remove_all(mi->options, "nfsvers");
>> +    }
>> +
>>     if (!nfs_validate_options(mi))
>>         return EX_FAIL;
>>
>> -- 
>> 1.6.2.1
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
------------------------------------------------------------
Kevin Constantine

Systems Engineer		t: 818.460.8221
Walt Disney Animation Studios	e: kevin.constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org

Any sufficiently advanced technology is indistinguishable from magic.
     - Arthur C. Clarke

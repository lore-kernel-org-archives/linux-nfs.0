From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 024/100] nfsd: move nfsd/auth.h into fs/nfsd
Date: Mon, 28 Jan 2008 13:13:29 -0500
Message-ID: <20080128181329.GB16785@fieldses.org>
References: <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <1201303040-7779-21-git-send-email-bfields@citi.umich.edu> <1201303040-7779-22-git-send-email-bfields@citi.umich.edu> <1201303040-7779-23-git-send-email-bfields@citi.umich.edu> <1201303040-7779-24-git-send-email-bfields@citi.umich.edu> <5DD4A881-9BED-47E9-A6A2-936CCCA6C4C4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	"Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbYA1SNb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 13:13:31 -0500
In-Reply-To: <5DD4A881-9BED-47E9-A6A2-936CCCA6C4C4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 12:24:35PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> This header is used only in a few places in fs/nfsd, so there seems to
>> be little point to having it in include/.  (Thanks to Robert Day for
>> pointing this out.)
>>
>> Cc: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
>> Acked-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/nfsd/auth.h               |   27 +++++++++++++++++++++++++++
>>  fs/nfsd/nfs3xdr.c            |    1 +
>>  fs/nfsd/nfsfh.c              |    1 +
>>  fs/nfsd/nfsxdr.c             |    1 +
>>  include/linux/nfsd/Kbuild    |    1 -
>>  include/linux/nfsd/auth.h    |   27 ---------------------------
>>  include/linux/nfsd/nfsd.h    |    1 -
>>  include/linux/nfsd/syscall.h |    1 -
>>  8 files changed, 30 insertions(+), 30 deletions(-)
>>  create mode 100644 fs/nfsd/auth.h
>>  delete mode 100644 include/linux/nfsd/auth.h
>>
>> diff --git a/fs/nfsd/auth.h b/fs/nfsd/auth.h
>> new file mode 100644
>> index 0000000..0fb9f72
>> --- /dev/null
>> +++ b/fs/nfsd/auth.h
>> @@ -0,0 +1,27 @@
>> +/*
>> + * include/linux/nfsd/auth.h
>
> Now that you've moved this header into fs/nfsd, the pathname in this  
> comment is no longer correct.  Usually hch complains about this; his  
> recommended solution is to remove the filename from the block comment  
> completely.

Right.  Done in the following patch along with some other cleanup.  It
seemed cleaner to do make the rename completely trivial to identify,
then fix the file conntents afterwards.

--b.

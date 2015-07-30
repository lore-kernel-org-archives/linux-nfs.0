Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35754 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbbG3MFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 08:05:47 -0400
Received: by pabkd10 with SMTP id kd10so22655754pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 05:05:47 -0700 (PDT)
Message-ID: <55BA130C.1050604@gmail.com>
Date: Thu, 30 Jul 2015 20:05:32 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: Re: [PATCH 3/4] 4.1 xdrdef: Fix bad define of sec_label4
References: <55B76B9B.4090700@gmail.com> <20150729193734.GB21949@fieldses.org>
In-Reply-To: <20150729193734.GB21949@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/30/2015 03:37, J. Bruce Fields wrote:
> On Tue, Jul 28, 2015 at 07:46:35PM +0800, Kinglong Mee wrote:
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
> 
> See nfs4.1/xdrdef/README and please update that README and nfs4.x.diff
> too if necessary (and report to nfsv4@ietf.org if this is still a bug in
> the minorversion 2 draft).

Description at,
https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-38#section-12.2.4

"The FATTR4_SEC_LABEL contains an array of two components with the
 first component being an LFS."

It seems both nfs server and client have wrong implement, not the rfc's bug.

xdrdef/nfs4.x is out of date, just update it.

thanks,
Kinglong Mee

> 
> --b.
> 
>>  nfs4.1/xdrdef/nfs4.x | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
>> index 024e0b4..cb3db7e 100644
>> --- a/nfs4.1/xdrdef/nfs4.x
>> +++ b/nfs4.1/xdrdef/nfs4.x
>> @@ -852,7 +852,7 @@ typedef change_policy4  fattr4_change_policy;
>>  typedef uint64_t        fattr_space_freed;
>>  typedef change_attr_type4
>>                  fattr4_change_attr_type;
>> -typedef sec_label4      fattr_sec_label<>;
>> +typedef sec_label4      fattr4_sec_label;
>>  
>>  %/*
>>  % * REQUIRED Attributes
>> -- 
>> 2.4.3
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:43416 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbaCFTG1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 14:06:27 -0500
Received: by mail-ie0-f169.google.com with SMTP id to1so3240694ieb.14
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 11:06:27 -0800 (PST)
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1028951407-1394132418-cardhu_decombobulator_blackberry.rim.net-599891631-@b5.c4.bise6.blackberry>
Date: Thu, 6 Mar 2014 14:06:24 -0500
Cc: Andrew Martin <amartin@xes-inc.com>, Jim Rees <rees@umich.edu>,
        Brown Neil <neilb@suse.de>, linux-nfs-owner@vger.kernel.org,
        linux-nfs@vger.kernel.org
Message-Id: <E22EB8B3-DE5E-4D39-8FFD-BA3F02276EFE@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <1028951407-1394132418-cardhu_decombobulator_blackberry.rim.net-599891631-@b5.c4.bise6.blackberry>
To: bhawley@luminex.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 14:00, Brian Hawley <bhawley@luminex.com> wrote:

> 
> Even with small timeo and retrans, you won't get i/o errors back to the reads/writes.   That's been our experience anyway.

Read caching, and buffered writes mean that the I/O errors often do not occur during the read()/write() system call itself.

We do try to propagate I/O errors back to the application as soon as the do occur, but if that application isn’t using synchronous I/O, and it isn’t checking the return values of fsync() or close(), then there is little the kernel can do...

> 
> With soft, you may end up with lost data (data that had already been written to the cache but not yet to the storage).   You'd have that same issue with 'hard' too if it was your appliance that failed.  If the appliance never comes back, those blocks can never be written.
> 
> In your case though, you're not writing.  
> 
> 
> -----Original Message-----
> From: Andrew Martin <amartin@xes-inc.com>
> Date: Thu, 6 Mar 2014 10:43:42 
> To: Jim Rees<rees@umich.edu>
> Cc: <bhawley@luminex.com>; NeilBrown<neilb@suse.de>; <linux-nfs-owner@vger.kernel.org>; <linux-nfs@vger.kernel.org>
> Subject: Re: Optimal NFS mount options to safely allow interrupts and
> timeouts on newer kernels
> 
>> From: "Jim Rees" <rees@umich.edu>
>> Andrew Martin wrote:
>> 
>>> From: "Jim Rees" <rees@umich.edu>
>>> Given this is apache, I think if I were doing this I'd use
>>> ro,soft,intr,tcp
>>> and not try to write anything to nfs.
>>  I was using tcp,bg,soft,intr when this problem occurred. I do not know if
>>  apache was attempting to do a write or a read, but it seems that
>>  tcp,soft,intr
>>  was not sufficient to prevent the problem.
>> 
>> I had the impression from your original message that you were not using
>> "soft" and were asking if it's safe to use it. Are you saying that even with
>> the "soft" option the apache gets stuck forever?
> Yes, even with soft, it gets stuck forever. I had been using tcp,bg,soft,intr
> when the problem occurred (on several ocassions), so my original question was
> if it would be safe to use a small timeo and retrans values to hopefully 
> return I/O errors quickly to the application, rather than blocking forever 
> (which causes the high load and inevitable reboot). It sounds like that isn't
> safe, but perhaps there is another way to resolve this problem?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


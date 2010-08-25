From: Harry Edmon <harry@uw.edu>
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
Date: Wed, 25 Aug 2010 09:49:33 -0700
Message-ID: <4C75499D.6050603@uw.edu>
References: <4C7407D2.1040304@uw.edu> <20100825105320.GA17190@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37304 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab0HYQtg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 12:49:36 -0400
Received: by pzk9 with SMTP id 9so265248pzk.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Aug 2010 09:49:35 -0700 (PDT)
In-Reply-To: <20100825105320.GA17190@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig wrote:
> Are you running xfs on this machine?  If so can you please try
> this patch:
>
> 	http://git.kernel.org/?p=linux/kernel/git/dgc/xfsdev.git;a=commitdiff;h=4536f2ad8b330453d7ebec0746c4374eadd649b1
>
>   
It is xfs.   I'm trying the patch now.

-- 
 Dr. Harry Edmon			E-MAIL: harry@uw.edu
 206-543-0547 FAX: 206-543-0308			harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
 Director of IT, College of the Environment and
 Director of Computing, Dept of Atmospheric Sciences
 University of Washington, Box 351640, Seattle, WA 98195-1640


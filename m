From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] rpc.statd: eliminate --secure_statd
Date: Thu, 4 Sep 2008 11:05:46 -0400
Message-ID: <76bd70e30809040805o141c52f5rc9e8b518f4dd7066@mail.gmail.com>
References: <20080902215132.31328.44934.stgit@manray.1015granger.net>
	 <20080902215354.31328.21471.stgit@manray.1015granger.net>
	 <18623.31606.828680.632520@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steved@redhat.com, okir@suse.de, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:54349 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbYIDPFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 11:05:47 -0400
Received: by an-out-0708.google.com with SMTP id d40so604282and.103
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2008 08:05:46 -0700 (PDT)
In-Reply-To: <18623.31606.828680.632520-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 4, 2008 at 2:08 AM, Neil Brown <neilb@suse.de> wrote:
> On Tuesday September 2, chuck.lever@oracle.com wrote:
>> -     /* Restrict access to statd.
>> -      * In the light of CERT CA-99.05, we tighten access to
>> -      * statd.                       --okir
>> -      */
>
> This is my only concern.  You've removed the reference to CERT
> CA-99.05.
> Maybe put it back in the new "caller_is_localhost" function??

Sure.  A signpost for those future developers who might consider
removing this function.

--
Chuck Lever

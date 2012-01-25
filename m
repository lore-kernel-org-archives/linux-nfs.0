Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43802 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180Ab2AYLNA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 06:13:00 -0500
Message-ID: <4F1FE3A8.5020002@parallels.com>
Date: Wed, 25 Jan 2012 15:12:40 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to
 named one
References: <4EFB330A.7070908@parallels.com> <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com> <4EFB521B.7060004@parallels.com> <406C7E87-0CCB-4034-8FD8-1602F7DCDBD6@oracle.com> <4EFC5391.7000601@parallels.com> <5E291DB3-7FB3-4108-B254-B59780C64346@oracle.com> <4EFC9189.5040605@parallels.com> <56767BFA-62B8-4E10-B9B3-4FD9EF278969@oracle.com> <4EFCA668.6040107@parallels.com>
In-Reply-To: <4EFCA668.6040107@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck, Bruce, have you seen this patch I'm replying to?
I would appreciate for any comments with this problem.
Also, probably we can instead just perform local transports socket connection in 
sync mode? This should solve our problem.
What do you think?

-- 
Best regards,
Stanislav Kinsbursky

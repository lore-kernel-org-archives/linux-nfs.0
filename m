Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39042 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933919AbcKJP6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 10:58:19 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Anna Schumaker" <Anna.Schumaker@Netapp.com>
Cc: "Trond Myklebust" <trondmy@primarydata.com>,
        "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>,
        "Oleg Drokin" <green@linuxhacker.ru>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
Date: Thu, 10 Nov 2016 10:58:09 -0500
Message-ID: <D4F8C627-7DDD-45FF-900E-253F4FB3F47B@redhat.com>
In-Reply-To: <806bf204-eb35-5a3a-30fa-612bf22fb09a@Netapp.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <599EE56B-46DD-411B-805D-11C2FB5E30A4@redhat.com>
 <34B1D68A-1A1C-4B59-A19E-467D48F7A9D0@redhat.com>
 <F1712484-1131-418A-98F0-272A4A1BAE59@redhat.com>
 <AB669741-1EC9-4C08-86A8-479755398679@redhat.com>
 <6ABCDB9B-997E-49C1-9363-D59AF9BEC0E9@primarydata.com>
 <B41EEA6E-B168-4DE3-AC73-F4270287EF0D@redhat.com>
 <806bf204-eb35-5a3a-30fa-612bf22fb09a@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

On 10 Nov 2016, at 10:01, Anna Schumaker wrote:
> Do you have an estimate for when this patch will be ready?  I want to 
> include it in my next bugfix pull request for 4.9.

I haven't posted because I am still trying to get to the bottom of 
another
problem where the client gets stuck in a loop sending the same stateid 
over
and over on NFS4ERR_OLD_STATEID.  I want to make sure this problem isn't
caused by this fix -- which I don't think it is, but I'd rather make 
sure.
If I don't make any progress on this problem by the end of today, I'll 
post
what I have.

Read on if interested in this new problem:

It looks like racing opens with the same openowner can be returned out 
of
order by the server, so the client sees stateid seqid of 2 before 1.  
Then a
LOCK sent with seqid 1 is endlessly retried if sent while doing 
recovery.

It's hard to tell if I was able to capture all the moving parts to 
describe
this problem, though.  As it takes a very long time for me to reproduce, 
and
the packet captures were dropping frames.  I'm working on manually
reproducing it now.

Ben

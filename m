Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41449 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030935Ab2HIPBZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 11:01:25 -0400
Received: by yhmm54 with SMTP id m54so530360yhm.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 08:01:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344522979.23523.2.camel@lade.trondhjem.org>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
 <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com> <1344522979.23523.2.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 9 Aug 2012 23:01:03 +0800
Message-ID: <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 10:36 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2012-08-09 at 22:30 +0800, Peng Tao wrote:
>> On Thu, Aug 9, 2012 at 4:21 AM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > Ever since commit 0a57cdac3f (NFSv4.1 send layoutreturn to fence
>> > disconnected data server) we've been sending layoutreturn calls
>> > while there is potentially still outstanding I/O to the data
>> > servers. The reason we do this is to avoid races between replayed
>> > writes to the MDS and the original writes to the DS.
>> >
>> > When this happens, the BUG_ON() in nfs4_layoutreturn_done can
>> > be triggered because it assumes that we would never call
>> > layoutreturn without knowing that all I/O to the DS is
>> > finished. The fix is to remove the BUG_ON() now that the
>> > assumptions behind the test are obsolete.
>> >
>> Isn't MDS supposed to recall the layout if races are possible between
>> outstanding write-to-DS and write-through-MDS?
>
> Where do you read that in RFC5661?
>
That's my (maybe mis-)understanding of how server works... But looking
at rfc5661 section 18.44.3. layoutreturn implementation.
"
After this call,
   the client MUST NOT use the returned layout(s) and the associated
   storage protocol to access the file data.
"
And given commit 0a57cdac3f, client is using the layout even after
layoutreturn, which IMHO is a violation of rfc5661.

>> And it causes data corruption for blocklayout if client returns layout
>> while there is in-flight disk IO...
>
> Then it needs to turn off fast failover to write-through-MDS.
>
If you still consider it following rfc5661, I'd choose to disable
layoutreturn in before write-through-MDS for blocklayout, by adding
some flag like PNFS_NO_LAYOUTRET_ON_FALLTHRU similar to objects'
PNFS_LAYOUTRET_ON_SETATTR.

-- 
Thanks,
Tao

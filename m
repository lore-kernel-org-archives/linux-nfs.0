Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754674Ab2DMQHf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 12:07:35 -0400
Message-ID: <4F884F32.7010402@RedHat.com>
Date: Fri, 13 Apr 2012 12:07:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        pstaubach@exagrid.com, miklos@szeredi.hu, viro@ZenIV.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr
 call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <20120413150518.GA1987@us.ibm.com> <20120413114236.0e557e01@tlielax.poochiereds.net>
In-Reply-To: <20120413114236.0e557e01@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/13/2012 11:42 AM, Jeff Layton wrote:
> On Fri, 13 Apr 2012 10:05:18 -0500
> Malahal Naineni <malahal@us.ibm.com> wrote:
> 
>> Jeff Layton [jlayton@redhat.com] wrote:
>>> 1) should we retry these calls on all filesystems, or attempt to have
>>> them "opt-in" in some fashion? This patch adds a flag for that, but
>>> we could just treat all filesystems the same way.
>>
>> I don't know any cases where a retry on ESTALE would hurt. I would say
>> retry on all file systems the same way.
>>
>>> 2) How many times should we retry on an ESTALE error? Once?
>>> Indefinitely? Some amount in between? Retrying once would probably
>>> fix the bulk of the real world problems with this, but there will
>>> still be cases where that's not sufficient.
>>
>> As you say 1 retry should work in most cases. Indefinitely doesn't make
>> sense, I would rather let my application fail! How about 3 retries (3 is
>> a nice number! :-) )
>>
> 
> (note: please don't trim the CC list!)
> 
> Indefinitely does make some sense (as Peter articulated in his original
> set). It's possible you could race several times in a row, or a server
> misconfiguration or something has happened and you have a transient
> error that will eventually recover. His assertion was that any limit on
> the number of retries is by definition wrong. For NFS, a fatal signal
> ought to interrupt things as well, so retrying indefinitely has some
> appeal there.
> 
> OTOH, we do have to contend with filesystems that might return ESTALE
> persistently for other reasons and that might not respond to signals.
> Miklos pointed out that some FUSE fs' do this in his review of Peter's
> set.
> 
> As a purely defensive coding measure, limiting the number of retries to
> something finite makes sense. If we're going to do that though, I'd
> probably recommend that we set the number of retries be something
> higher just so that this is more resilient in the face of multiple
> races. Those other fs' might "spin" a bit in that case but it is an
> error condition and IMO resiliency trumps performance -- at least in
> this case.
I'm of the opinion retry more than once has the potential of 
doing more harm than good... Why introduce looping when there
is no solid evidence its even needed. 

I would think 99% of the time the one try would solve the problem. 
That 1% probably due two apps that have gone wild fight over the same 
file or the FUSE case. In those cases the error should be returned
IMHO... 

steved.

> 
> Of course, if we're going to do this for all fs', then we probably
> ought to try to handle ESTALEs that are encountered in the pathwalking
> code in a similar way. That may mean changing do_path_lookup and
> do_filp_open_* to reattempt several times on an ESTALE error.
> 

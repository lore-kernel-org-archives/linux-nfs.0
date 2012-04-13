Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c12o141.mxlogic.net ([208.65.145.74]:58557 "EHLO
	p02c12o141.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab2DMRhU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Apr 2012 13:37:20 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Jeff Layton <jlayton@redhat.com>, Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>
Date: Fri, 13 Apr 2012 13:34:51 -0400
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <2F609A9B-B44B-4CEA-BF35-D6BEDA729363@exagrid.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
 <20120413150518.GA1987@us.ibm.com>
 <20120413114236.0e557e01@tlielax.poochiereds.net>
 <4F884F32.7010402@RedHat.com>
In-Reply-To: <4F884F32.7010402@RedHat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I still think that returning ESTALE to the application is just exposing a short coming in the implementation.  From a path based system like stat(), the application should see either ENOENT or some sort valid return.

I also look at the looping from the other side.  While possible, of course, I'd like to see someone construct a situation where it really happens.  By this, I don't mean a thought experiment, but a real running situation.

We already have evidence, in the form of the Solaris NFS client, that infinite looping does not happen in nature.

        Thanx...

                ps


Sent from my iPhone

On Apr 13, 2012, at 12:07 PM, "Steve Dickson" <SteveD@redhat.com> wrote:

> 
> 
> On 04/13/2012 11:42 AM, Jeff Layton wrote:
>> On Fri, 13 Apr 2012 10:05:18 -0500
>> Malahal Naineni <malahal@us.ibm.com> wrote:
>> 
>>> Jeff Layton [jlayton@redhat.com] wrote:
>>>> 1) should we retry these calls on all filesystems, or attempt to have
>>>> them "opt-in" in some fashion? This patch adds a flag for that, but
>>>> we could just treat all filesystems the same way.
>>> 
>>> I don't know any cases where a retry on ESTALE would hurt. I would say
>>> retry on all file systems the same way.
>>> 
>>>> 2) How many times should we retry on an ESTALE error? Once?
>>>> Indefinitely? Some amount in between? Retrying once would probably
>>>> fix the bulk of the real world problems with this, but there will
>>>> still be cases where that's not sufficient.
>>> 
>>> As you say 1 retry should work in most cases. Indefinitely doesn't make
>>> sense, I would rather let my application fail! How about 3 retries (3 is
>>> a nice number! :-) )
>>> 
>> 
>> (note: please don't trim the CC list!)
>> 
>> Indefinitely does make some sense (as Peter articulated in his original
>> set). It's possible you could race several times in a row, or a server
>> misconfiguration or something has happened and you have a transient
>> error that will eventually recover. His assertion was that any limit on
>> the number of retries is by definition wrong. For NFS, a fatal signal
>> ought to interrupt things as well, so retrying indefinitely has some
>> appeal there.
>> 
>> OTOH, we do have to contend with filesystems that might return ESTALE
>> persistently for other reasons and that might not respond to signals.
>> Miklos pointed out that some FUSE fs' do this in his review of Peter's
>> set.
>> 
>> As a purely defensive coding measure, limiting the number of retries to
>> something finite makes sense. If we're going to do that though, I'd
>> probably recommend that we set the number of retries be something
>> higher just so that this is more resilient in the face of multiple
>> races. Those other fs' might "spin" a bit in that case but it is an
>> error condition and IMO resiliency trumps performance -- at least in
>> this case.
> I'm of the opinion retry more than once has the potential of 
> doing more harm than good... Why introduce looping when there
> is no solid evidence its even needed. 
> 
> I would think 99% of the time the one try would solve the problem. 
> That 1% probably due two apps that have gone wild fight over the same 
> file or the FUSE case. In those cases the error should be returned
> IMHO... 
> 
> steved.
> 
>> 
>> Of course, if we're going to do this for all fs', then we probably
>> ought to try to handle ESTALEs that are encountered in the pathwalking
>> code in a similar way. That may mean changing do_path_lookup and
>> do_filp_open_* to reattempt several times on an ESTALE error.
>> 

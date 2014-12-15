Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751931AbaLONkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2014 08:40:51 -0500
Date: Mon, 15 Dec 2014 08:40:47 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Pablo Silva <psilvao@gmail.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: NFS and Memory Buffers
In-Reply-To: <CAF1in6SGo2k9FB4O+5ALTMpVtW=kTkSGponiY7w2XjuX_p=pTQ@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1412150836110.1119@planck.local>
References: <CAF1in6QVkgyuC7VQ5QdYnYtPRJgArDwg5sXtKiAvyszCcQoZ-g@mail.gmail.com> <CAF1in6RCyK4VMM3j1ZD=1D25+cFU9YGg-UhR-kuYcNWNk+Stzg@mail.gmail.com> <alpine.OSX.2.19.9992.1412150749290.1119@planck.local> <CAF1in6QpHmj6Y3UurtZvjsvX2se3DqTWqNxVmYtd2i+xUnEVug@mail.gmail.com>
 <alpine.OSX.2.19.9992.1412150803320.1119@planck.local> <CAF1in6SGo2k9FB4O+5ALTMpVtW=kTkSGponiY7w2XjuX_p=pTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think your question is "why is the memory not automatically released?"
It is not being released because nothing else requires the use of that
memory.

Ben

On Mon, 15 Dec 2014, Pablo Silva wrote:

> Thanks Benjamin for your comment, well ..
>
> After the memory buffer is released, my Boos and colleague OpenNMS
> observed by passing a time period and is refilled, and therefore an
> alarm is triggered indicating opennms:
>
> Low threshold exceeded for SNMP datasource (memAvailReal + memcached)
> / memTotalReal * 100.0 interface on 172.16.10.37, parms: label =
> "Unknown" ds = "(memAvailReal + memcached) / memTotalReal * 100.0"
> value = "4.65" instance = "null "instanceLabel =" null "resourceId ="
> node [799] .nodeSnmp [] "trigger =" 2 "rearm =" 10.0 "threshold =" 5.0
> "
>
> I have the graphic, but could send tinypic, if the list to send
> messages with pictures.
>
> Doubt my Boss is why the buffer memory is not released and growing
> without anything to release him unless use of the commands that I sent
> is made.
>
> The only service that is running there is NFS, which uses the default settings.
>
> [root @ bck ~] # cat / etc / exports
> / backup * (rw, sync)
> / BACKUP / RESPALDO01 172.16.30.4 (rw, insecure, sync, no_wdelay,
> no_root_squash)
>
>  I told them that's no problem using buffer memory, and it is natural
> that Linux consumes memory and administer, but my Boss on reason not
> automatically releases the buffer memory persists.
>
> The current reading is:
>
> [root@bck ~]# free -m
>              total       used       free     shared    buffers     cached
> Mem:         15936      15748        188          0       4095      10770
> -/+ buffers/cache:        881      15055
> Swap:         2047          0       2047
> [root@bck ~]#
>
>
>   -Pablo
>
> On Mon, Dec 15, 2014 at 10:08 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > What you're doing does result in the cache being flushed, only to
> > immediately start to fill again.
> >
> > I should have replied more to the point as Trond did: this is normal, do
> > not worry.  Your memory is not being "used up", as the cache memory is given
> > back to the system if it is needed for other use.
> >
> > Ben
> >
> > On Mon, 15 Dec 2014, Pablo Silva wrote:
> >
> >> Dear Benajmin;
> >>
> >>      A colleague sent me this information as is, but the curious thing
> >> which does not release the memory buffer, except using the commands
> >> that you can appreciate.
> >>
> >> I am investigating if possible "know" that information is being stored
> >> there, and from what I see there is a command linux-fTools that could
> >> help me descubir the information being stored there, do not know if I
> >> bring in my analysis but it is my first step, I do not know if you
> >> have any other suggestions.
> >>
> >> grateful
> >>
> >> - Pablo
> >>
> >> On Mon, Dec 15, 2014 at 9:52 AM, Benjamin Coddington
> >> <bcodding@redhat.com> wrote:
> >> > Dear Pablo,
> >> >
> >> >         Why are you restarting snmpd between flushing cache and reading
> >> > memory values?  On a running system you can probably expect the
> >> > cache to immediately start to fill after a flush anyway.
> >> > y
> >> > Ben
> >> >
> >> > On Mon, 15 Dec 2014, Pablo Silva wrote:
> >> >
> >> >> Dear Readers:
> >> >>
> >> >>      My boss has entrusted me to analyze why the memory buffers are
> >> >> not released a Linux server with Centos 6.4.?
> >> >>
> >> >>     As informs me, the current reading is:
> >> >>
> >> >>
> >> >> [root@bck ~]# free -m
> >> >>              total       used       free     shared    buffers     cached
> >> >> Mem:         15936      15788        147          0       6746        438
> >> >> -/+ buffers/cache:       8604       7332
> >> >> Swap:         2047          0       2047
> >> >> [root@bck ~]#
> >> >> [root@bck ~]#
> >> >> [root@bck ~]# echo 3 > /proc/sys/vm/drop_caches && service snmpd
> >> >> restart && free -m
> >> >> Stopping snmpd:                                            [  OK  ]
> >> >> Starting snmpd:                                            [  OK  ]
> >> >>              total       used       free     shared    buffers     cached
> >> >> Mem:         15936        509      15426          0         93         16
> >> >> -/+ buffers/cache:        400      15536
> >> >> Swap:         2047          0       2047
> >> >> [root@bck ~]#
> >> >>
> >> >>    I can not find the solution to release the memory buffer and cache
> >> >> memory so grateful for any hint for finding the solution to this
> >> >> "problem".
> >> >>
> >> >> -Paul
> >> >> --
> >> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> >> the body of a message to majordomo@vger.kernel.org
> >> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> >>
> >>
>

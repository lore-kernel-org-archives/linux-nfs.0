Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f182.google.com ([209.85.217.182]:47636 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756346Ab3HGIFz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 04:05:55 -0400
Received: by mail-lb0-f182.google.com with SMTP id v20so1249004lbc.41
        for <linux-nfs@vger.kernel.org>; Wed, 07 Aug 2013 01:05:53 -0700 (PDT)
Received: from [192.168.43.130] ([217.118.81.51])
        by mx.google.com with ESMTPSA id am8sm2235525lac.1.2013.08.07.01.05.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Aug 2013 01:05:53 -0700 (PDT)
Subject: Re: NFS4 server, performance and cache consistency in comparison with solaris.
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <20130731071527.5c68e5e8@tlielax.poochiereds.net>
Date: Wed, 7 Aug 2013 09:47:56 +0200
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>, smayhew@redhat.com
Message-Id: <CAENLDB_gm4wcXfT3BhD1SMQiuKdW6+APvd+gn5p96gODYzT6zA@mail.gmail.com>
References: <E774E8EC-5CC0-436F-A8F3-0AB84534C316@gmail.com> <7385CFE1-E63F-45C5-A38C-59C6FC4F0C5C@gmail.com> <20130731071527.5c68e5e8@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>
> On Jul 31, 2013, at 6:35 AM, Anton Starikov <ant.starikov@gmail.com> wrote:
>
> > Hey,
> >
> > we are in the process of migration of our storage from solaris to linux (RHEL6) and I see some strange things, which depends on server side.
> >
> > In our old solaris setup we have slower network (1GbE vs 10GbE), much slower storage than new one, but still when I export volume with default solaris options and mount on linux clients with options:
> > rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,minorversion=0,local_lock=none
> >

> >
> > When I export from linux host with options:
> >
> > rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,no_acl,mountpoint,anonuid=65534,anongid=65534,sec=sys,rw,no_root_squash,no_all_squash (it is options as shown in /var/lib/nfs/etab),
> >
> > and mount on linux clients with the same options as with old setup, I have great "dbench 4" performance (about 200Mb/s), but consistency is nonexistent, in the same case (one client keep writing to file, second is reading), on second client I can see state of file with delayed for 5-30 secs. Out of curiosity I tried to use "sync" in loop on a first client (where it writes) to flush cache, but it does not affect something. File isn't really large, but client updates it 2-4 times a sec.
> >
> > All my attempts to improve consistency had two possible impacts:
> >
> > 1) either still luck of consistency (like actimeo=0,lookupcache=none) and reasonable or good dbench results.
> > 2) consistency is recovered (or almost recovered) (like sync, noac), but dbench results drops to 10MB/s or even less!
> >
> > Taking into account that mounting happens with the same options on a client side in both cases, it there some server-side trick with options?
> >
> > Time is synchronised between hosts.
> >
> > Anton.
>


This is all due to client-side effects, so there's little you can do
server-side to affect this.

lookupcache= option probably won't make a lot of difference here, but
actimeo= option likely would. actimeo= means that the client never
caches attributes, so every time it needs to check cache coherency it
has to issue a GETATTR to the server. Dialing this to a more reasonable
value (e.g. actimeo=1 or so) should still give you pretty tight cache
coherency w/o killing performance too badly.

The cache coherency logic in the Linux NFS client is pretty complex,
but typically when you have a file that's changing rapidly it should
quickly dial down the attribute cache timeout to the default minimum
(3s). None of that matters though unless you have the "writing" client
aggressively flushing the dirty data out to the server.

--
Jeff Layton <jlayton@redhat.com>


Then why results depend on the server?
the same client mount options results in quite different results with linux and solaris servers.
there is clearly must be something.

Anton.
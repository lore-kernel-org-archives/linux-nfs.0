Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:36171 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756768AbcCaNei (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2016 09:34:38 -0400
Received: by mail-oi0-f44.google.com with SMTP id r187so60311037oih.3
        for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 06:34:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87io03s0ak.fsf@notabene.neil.brown.name>
References: <20160321143914.GA6397@anthem.async.com.br>
	<20160322005813.GA3378@anthem.async.com.br>
	<87io03s0ak.fsf@notabene.neil.brown.name>
Date: Thu, 31 Mar 2016 09:34:37 -0400
Message-ID: <CAHQdGtT+Uwj9zuX+KqB92sVjzcOChvOmr1UDN-ZMQdSURhvWwg@mail.gmail.com>
Subject: Re: Finding and breaking client locks
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <nfbrown@novell.com>
Cc: Christian Robottom Reis <kiko@acm.org>,
        NFS List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 31, 2016 at 1:07 AM, NeilBrown <nfbrown@novell.com> wrote:
>
> On Tue, Mar 22 2016, Christian Robottom Reis wrote:
>
> > On Mon, Mar 21, 2016 at 11:39:14AM -0300, Christian Robottom Reis wrote:
> >> indeed does not return any information pertaining NFS client locks, and
> >> I'm not clear whether /proc/locks (on the server side obviously) does or
> >> not.
> >
> > Somewhat OT, but I find it a PITA that /proc/locks gives inode numbers
> > that then need to be looked up individually. I have often been surprised
> > no tool exists to parse that and give you back a report of filenames, so
> > I just put together a small tool that just offloads the work to debugfs.
> >
> > I've attached it in case others might find it useful.
>
> Nice idea, though it only works with extXfs - better than nothing
> though.
>
> It would be really easy to do this in the kernel.
> I would be very much in favour of a /proc/locks-extended (or whatever)
> that provides the same information as /proc/locks, but in a format
> which includes full path name, process name, and - for nfs locks -
> client name etc.

Why isn't the current interface sufficient? The 'lslocks' utility
appears quite capable of extracting the full path info.

Cheers
  Trond

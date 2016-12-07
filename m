Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932332AbcLGOfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 09:35:15 -0500
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
 <79c2889c-3a77-7fcb-37d0-8fd970b54be7@RedHat.com>
 <87twag4ro2.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <3640664f-c8d8-291b-efc3-2b5d1df14f9b@RedHat.com>
Date: Wed, 7 Dec 2016 09:34:55 -0500
MIME-Version: 1.0
In-Reply-To: <87twag4ro2.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2016 05:30 PM, NeilBrown wrote:
>> I'm curious as to what the criteria was as to
>> which options were defined. I would think 'debug'
>> and 'port' would have made the list.
> port should have made the list, it just .... didn't.
Sure... I'll add it... 

> 
> debug was more of a deliberate omission, or at least a deferral.
> I didn't include debug for any daemons. mountd, nfsd, nfsdcltrack all
> allow the option.  statd blends it with no-syslog. sm-notify has "-d".
> mountd's --debug is different to the other, and takes word, as does
> "exportfs -d".  The word is passed to xlog_sconfig can can select from
> general, call, auth, parse, all.
For the ones that take a word, we could make debug=1 mean 
--debug all as the default. If other types of debug is 
need the command like can always be used. 

> 
> Assuming that we want to be able to enable debug in the config file
> (wouldn't you just run that command manually when you want to enable
> debugging?) it would be good to standardize somehow.
Hopefully through the nfs.conf file things can be standardized.
I'm not sure we want change command line arguments for
that reason though... 
 
> 
> So I guess I was treating "debug" like "host" - do it later.
> I have no excuse for "port" :-(
Sounds good... 

steved.

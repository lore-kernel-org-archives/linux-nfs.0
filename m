Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 124-84-246-161.wendulka.net ([84.246.161.124]:51582 "EHLO
	ixit.cz" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751686AbaCLVwH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 17:52:07 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 12 Mar 2014 23:52:31 +0100
From: David Heidelberger <david.heidelberger@ixit.cz>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Al Viro <viro@ftp.linux.org.uk>
Subject: Re: DNOTIFY to INOTIFY migration
In-Reply-To: <20140310014551.GI18016@ZenIV.linux.org.uk>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
 <20140310102102.3c886726@notabene.brown>
 <20140310002015.GH18016@ZenIV.linux.org.uk>
 <20140310115659.098a7c06@notabene.brown>
 <20140310014551.GI18016@ZenIV.linux.org.uk>
Message-ID: <8ecb362fb052a6dd1d1d1899fd38783f@ixit.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil, what you think? Should I try someway simplify this as Al proposed?

Dne 2014-03-10 02:45, Al Viro napsal:
> On Mon, Mar 10, 2014 at 11:56:59AM +1100, NeilBrown wrote:
> 
>> > I still don't understand WTF does rpc.imapd *want* either of those, TBH.
>> 
>> The rpc_pipefs filesysem which is mounted on /var/lib/nfs/rpc_pipefs 
>> creates
>> new channels for talking to userspace by making new pipes appear in 
>> some
>> directory.  Any client needs to arrange some notification for these 
>> new pipes
>> appearing so that it can open them and hold a conversation over them.
>> This calls for dnotify (in gssd and idmapd) or inotify (in blkmapd).
> 
> ... or just adding ->poll() to the directory in question and using the
> normal syscalls instead of all that weird crap.

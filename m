Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 124-84-246-161.wendulka.net ([84.246.161.124]:48298 "EHLO
	ixit.cz" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752116AbaCIXzD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 19:55:03 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Mon, 10 Mar 2014 01:55:15 +0100
From: David Heidelberger <david.heidelberger@ixit.cz>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
In-Reply-To: <20140310102102.3c886726@notabene.brown>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
 <20140310102102.3c886726@notabene.brown>
Message-ID: <c90a00fb90b35b2ac904056383a3d532@ixit.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dne 2014-03-10 00:21, NeilBrown napsal:
> On Fri, 07 Mar 2014 21:30:34 +0100 David Heidelberger
> <david.heidelberger@ixit.cz> wrote:
> 
>> Hello,
>> 
>> in linux kernel is DNOTIFY actually marked as deprecated, with 
>> superior
>> replacement INOTIFY.
> 
> Where is it marked as deprecated?  I would be very surprised if dnotify
> wasn't supported indefinitely.


Dnotify is a directory-based per-fd file change notification system
	  that uses signals to communicate events to user-space.  There exist
	  superior alternatives, but some applications may still rely on
	  dnotify.

(fs/notify/dnotify/Kconfig)

In this moment, for modern systems I'm no aware of software actually 
using DNOTIFY.

Actually there is choice between INOTIFY and FSNOTIFY.
> 
> (I have no opinion on whether rpc.idmapd should be changed to use 
> inotify,
> except based on the "if it ain't broke, don't fix it" principle).

Well, I'd like to propose build option which notify system include. It 
seems like *notify support reside only in rpc.idmapd, so it shouldn't be 
hard.

David
> 
> NeilBrown
> 
>> 
>> Is any plan to migrate rpc.idmapd to INOTIFY? As I looked, it's just 
>> one
>> file.
>> 
>> If there is some on-going porting, I'd like to test/report bugs/send
>> patches, otherwise I'd like to try port it.
>> 
>> Thank you for answer
>> David Heidelberger (okias)
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
	part)
Date: Wed, 5 Aug 2009 14:15:45 -0400
Message-ID: <20090805181545.GF9944@fieldses.org>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39291 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbZHESPr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 14:15:47 -0400
In-Reply-To: <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2009 at 02:05:44PM -0400, Chuck Lever wrote:
> On Aug 5, 2009, at 1:48 PM, J. Bruce Fields wrote:
>> On Wed, Aug 05, 2009 at 10:45:40AM -0400, Chuck Lever wrote:
>>> Provide a new implementation of statd that supports IPv6.  The new
>>> statd implementation resides under
>>>
>>>  utils/new-statd/
>>>
>>> The contents of this directory are built if --enable-tirpc is set
>>> on the ./configure command line, and sqlite3 is available on the
>>> build system.  Otherwise, the legacy version of statd, which still
>>> resides under utils/statd/, is built.
>>>
>>> The goals of this re-write are:
>>>
>>> o Support IPv6 networking
>>>
>>>   Support interoperation with TI-RPC-based NSM implementations.
>>>   Transport Independent RPC, or TI-RPC, provides IPv6 network support
>>>   for Linux's NSM implementation.
>>>
>>>   To support TI-RPC, open code to construct RPC requests in socket
>>>   buffers and then schedule them has been replaced with standard
>>>   library calls.
>>>
>>> o Support notification via TCP
>>>
>>>   As a secondary benefit of using TI-RPC library calls, reboot
>>>   notifications and NLM callbacks can now be sent via connection-
>>>   oriented transport protocols.
>>>
>>>   Note that lockd does not (yet) tell statd what transport protocol
>>>   to use when sending reboot notifications.  statd/sm-notify will
>>>   continue to use UDP for the time being.
>>>
>>> o Use an embedded database for storing on-disk callback data
>>>
>>>   This whole exercise is for the purpose of crash robustness.  There
>>>   are well-known deficiencies with simple create/rename/unlink
>>>   disk storage schemes during system crashes.  Replace the current
>>>   flat-file monitor list mechanism which uses sync(2) with sqlite3,
>>>   which uses fsync(3).
>>
>> If someone wants to move around that data, is it still simple to do
>> that?  (Where is it kept on the filesystem?)
>>
>> (I'm thinking of someone that shares it for high-availabity, as in:
>>
>> 	http://www.howtoforge.com/high_availability_nfs_drbd_heartbeat_p3
>>
>> Or maybe somebody that just needs to move their /var partition to a
>> different disk one day.)
>
> Statd's monitor lists and state number are stored in a single regular  
> file, /var/lib/nfs/statd/statdb by default.  This file can be easily  
> backed up, or used on other systems, if desired.  I would recommend  
> ensuring the NSM state number is reset in the latter case, which can be 
> done with the sqlite3 command.
>
> I've had some dialog with Lon Hohberger about clustering requirements.  I 
> think we are looking at crafting a separate utility that uses sqlite3 C 
> function calls to extract data that's interesting to the clustering 
> implementation.  Again, this could even be scripted with bash and the 
> sqlite3 command, but perhaps a C program is more maintainable.

OK, good.

And for the simplest cases, it should still be enough to just copy
/var/lib/nfs/, right?

--b.

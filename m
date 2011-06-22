Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51911 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757939Ab1FVOyA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 10:54:00 -0400
Message-ID: <4E020205.1000308@candelatech.com>
Date: Wed, 22 Jun 2011 07:53:57 -0700
From: Ben Greear <greearb@candelatech.com>
To: Steve Dickson <SteveD@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfs-utils:  Support binding to source address.
References: <1308000408-13690-1-git-send-email-greearb@candelatech.com> <4DFF8604.1050508@candelatech.com> <4E01FC5B.1000509@RedHat.com>
In-Reply-To: <4E01FC5B.1000509@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/22/2011 07:29 AM, Steve Dickson wrote:
> Sorry for the delay.. I was traveling last week..
>
> On 06/20/2011 01:40 PM, Ben Greear wrote:
>> On 06/13/2011 02:26 PM, greearb@candelatech.com wrote:
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> This lets one specify the source IP address for
>>> sockets, allowing users to leverage routing rules
>>> on multi-homed systems.
>>>
>>> Kernel patches to RPC and NFS are needed to complete
>>> full functionality.
>>
>> Any feedback on this?  Good enough for inclusion upstream?
> Question, are there kernel patches needed to complete this work?
>
> steved.

Yes, posted a week or two ago as RFC:

http://www.spinics.net/lists/linux-nfs/msg21802.html

Thanks,
Ben

>
>>
>> Thanks,
>> Ben
>>
>>>
>>> v6:  Remove is_set flag from local_bind_info struct.  Just pass in
>>>          NULL if local IP is not specified.
>>>        Use family of server when parsing local IP address.  This makes
>>>          sure that we do not get a family mis-match between server and
>>>          local ip.
>>>        Rename parse_local_bind to nfs_parse_local_bind
>>>        Clean up a few nits (don't check for null before freeing something).
>>>
>>> v5:  Fix compile error with ipv6 enabled.  One minor
>>>          change to patch 1.
>>>
>>> v4:  Remove get_socket() modifications: stropt mount doesn't use them.
>>>          (This removed old patch 4, and modified patch 1)
>>>        Remove open-parsing of srcaddr= in mount logic.  Move parsing
>>>          to nfs_validate_options()
>>>
>>> *** BLURB HERE ***
>>>
>>> Ben Greear (6):
>>>     nfs-utils:  Add structure for passing local binding info.
>>>     nfs-utils:  Add patch to parse srcaddr= option.
>>>     nfs-utils:  Implement srcaddr binding in rpc_socket
>>>     nfs-utils:  Support srcaddr=n option for string mount.
>>>     nfs-utils:  Implement srcaddr=n binding for unmount.
>>>     nfs-utils:  Update man page for srcaddr= option.
>>>
>>>    support/include/nfsrpc.h   |   23 ++++++---
>>>    support/include/sockaddr.h |    5 ++
>>>    support/nfs/getport.c      |   39 +++++++++-----
>>>    support/nfs/rpc_socket.c   |   96 ++++++++++++++++++++++++----------
>>>    utils/gssd/gssd.h          |    2 +
>>>    utils/gssd/gssd_proc.c     |   33 +++++++-----
>>>    utils/mount/network.c      |  125 +++++++++++++++++++++++++++++++++++---------
>>>    utils/mount/network.h      |   17 ++++--
>>>    utils/mount/nfs.man        |    7 +++
>>>    utils/mount/nfsmount.c     |    2 +-
>>>    utils/mount/nfsumount.c    |   28 ++++++++--
>>>    utils/mount/stropts.c      |   28 ++++++++--
>>>    utils/mount/utils.c        |    6 ++-
>>>    utils/mount/utils.h        |    4 +-
>>>    14 files changed, 310 insertions(+), 105 deletions(-)
>>>
>>
>>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

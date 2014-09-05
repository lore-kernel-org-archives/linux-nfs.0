Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:38919 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaIETlE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 15:41:04 -0400
Received: by mail-vc0-f170.google.com with SMTP id la4so13066555vcb.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 12:41:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+Tkd6WV9K4oZPVGkqL_y6OcD9Pmj6x0roo9n839QD8RXDsCwA@mail.gmail.com>
References: <CA+Tkd6URVCziomwWMFYtxmQyybpC7=r_BTjnwVuduDaOa4cuvg@mail.gmail.com>
 <20140903070048.56201d1d@tlielax.poochiereds.net> <70D58138-CB00-433C-8BF8-01584E6460F0@oracle.com>
 <CA+Tkd6WV9K4oZPVGkqL_y6OcD9Pmj6x0roo9n839QD8RXDsCwA@mail.gmail.com>
From: Chris Perl <chris.perl@gmail.com>
Date: Fri, 5 Sep 2014 15:40:42 -0400
Message-ID: <CA+Tkd6WYkkVbY2YsmRNHB4+9AFg5UjC1xoycLTZQOYrtFCT_2w@mail.gmail.com>
Subject: Re: nfs-utils - TCP ephemeral port exhaustion results in mount failures
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just submitted two patches, one for nfs-utils and one for linux-nfs.

As I said in my previous email, the patch to nfs-utils was enough to
get us farther along, but we failed inside mount(2) with EIO (with a
decidedly more confusing error message).

So, I've also submitted a patch for the rpc code in the kernel that
also avoids bind when asking for a random ephemeral port.  I've tested
the combination of these two patches with my system while in the
situation I originally outlined.  I can continue to successfully mount
NFS filesystems using both of these patches.

I don't particularly love the kernel patch, as it makes `xs_bind' not
actually bind in all circumstances, which seems confusing.  However, I
thought trying to rework things in a larger way would cause more
issues given that I'm not very familiar with this code.  If everyone
hates it, I can try something else.

The nfs-utils patch was on top of
82ab4b4e80199d606e5c40f373aaf384d3dfc081 (if it makes any difference)
as I couldn't build from newer commits on my CentOS 6.5 based system
because my keyutils-libs doesn't have `keyctl_invalidate' and there
was no obvious upgrade available.

Let me know if there is anything else I should do, or if I've done
anything obviously wrong.

On Wed, Sep 3, 2014 at 4:01 PM, Chris Perl <chris.perl@gmail.com> wrote:
> Thanks, I started putting something together, but have to do a little
> more digging.
>
> While making mount.nfs(8) only call connect(2) and not bind(2) gets us
> farther, we then fail in mount(2) (get an EIO) due to the in kernel
> rpc client invoking `xs_bind', which calls `kernel_bind', which calls
> `sock->ops->bind', which is the same thing bind(2) invokes and so it
> fails with EADDRINUSE.
>
> On Wed, Sep 3, 2014 at 9:55 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> On Sep 3, 2014, at 7:00 AM, Jeff Layton <jeff.layton@primarydata.com> wrote:
>>
>>> On Tue, 2 Sep 2014 12:51:06 -0400
>>> Chris Perl <chris.perl@gmail.com> wrote:
>>>
>>>> I've noticed that mount.nfs calls bind (in `nfs_bind' in
>>>> support/nfs/rpc_socket.c) before ultimately calling connect when
>>>> trying to get a tcp connection to talk to the remote portmapper
>>>> service (called from `nfs_get_tcpclient' which is called from
>>>> `nfs_gp_get_rpcbclient').
>>>>
>>>> Unfortunately, this means you need to find a local ephemeral port such
>>>> that said ephemeral port is not a part of *any* existing TCP
>>>> connection (i.e. you're looking for a unique 2 tuple of (socket_type,
>>>> local_port) where socket_type is either SOCK_STREAM or SOCK_DGRAM, but
>>>> in this case specifically SOCK_STREAM).
>>>>
>>>> If you were to just call connect without calling bind first, then
>>>> you'd need to find a unique 5 tuple of (socket_type, local_ip,
>>>> loacl_port, remote_ip, remote_port).
>>>>
>>>> The end result is a misbehaving application that creates many
>>>> connections to some service, using all ephemeral ports, can cause
>>>> attempts to mount remote NFS filesystems to fail with EADDRINUSE.
>>>>
>>>> Don't get me wrong, I think we should fix our application, (and we
>>>> are) but I don't see any reason why mount.nfs couldn't just call
>>>> connect without calling bind first (thereby allowing it to happen
>>>> implicitly) and allowing mount.nfs to continue to work in this
>>>> situation.
>>>>
>>>> I think an example may help explain what I'm talking about.
>>>>
>>>> Lets take a Linux machine running CentOS 6.5
>>>> (2.6.32-431.1.2.0.1.el6.x86_64) and restrict the number of available
>>>> ephemeral ports to just 10:
>>>>
>>>> [cperl@localhost ~]$ cat /proc/sys/net/ipv4/ip_local_port_range
>>>> 60000   60009
>>>>
>>>> Then create a TCP connection to a remote service which will just hold
>>>> that connection open:
>>>>
>>>> [cperl@localhost ~]$ for in in {0..9}; do socat -u
>>>> tcp:192.168.1.12:9990 file:/dev/null & done
>>>> [1] 21578
>>>> [2] 21579
>>>> [3] 21580
>>>> [4] 21581
>>>> [5] 21582
>>>> [6] 21583
>>>> [7] 21584
>>>> [8] 21585
>>>> [9] 21586
>>>> [10] 21587
>>>>
>>>> [cperl@localhost ~]$ netstat -n --tcp | awk '$6 ~ /ESTABLISHED/ && $5
>>>> ~/:999[0-9]$/ {print $1, $4, $5}' | sort | column -t
>>>> tcp  192.168.1.11:60000  192.168.1.12:9990
>>>> tcp  192.168.1.11:60001  192.168.1.12:9990
>>>> tcp  192.168.1.11:60002  192.168.1.12:9990
>>>> tcp  192.168.1.11:60003  192.168.1.12:9990
>>>> tcp  192.168.1.11:60004  192.168.1.12:9990
>>>> tcp  192.168.1.11:60005  192.168.1.12:9990
>>>> tcp  192.168.1.11:60006  192.168.1.12:9990
>>>> tcp  192.168.1.11:60007  192.168.1.12:9990
>>>> tcp  192.168.1.11:60008  192.168.1.12:9990
>>>> tcp  192.168.1.11:60009  192.168.1.12:9990
>>>>
>>>> And now try to mount an NFS export:
>>>>
>>>> [cperl@localhost ~]$ sudo mount 192.168.1.100:/export/a /tmp/a
>>>> mount.nfs: Address already in use
>>>>
>>>> As mentioned before, this is because bind is trying to find a unique 2
>>>> tuple of (socket_type, local_port) (really I believe its the 3 tuple
>>>> (socket_type, local_ip, local_port), but calling bind with INADDR_ANY
>>>> as `nfs_bind' does reduces it to the 2 tuple), which it cannot do.
>>>>
>>>> However, just calling connect allows local ephemeral ports to be
>>>> "reused" (i.e. it looks for the unique 5 tuple of (socket_type,
>>>> local_ip, local_port, remote_ip, remote_port)).
>>>>
>>>> For example, notice how the local ephemeral ports 60003 and 60004 are
>>>> "reused" below (because socat is just calling connect, not bind,
>>>> although we can make socat call bind with an option if we want and see
>>>> it fail like mount.nfs did above):
>>>>
>>>> [cperl@localhost ~]$ socat -u tcp:192.168.1.12:9991 file:/dev/null &
>>>> [11] 22433
>>>> [cperl@localhost ~]$ socat -u tcp:192.168.1.13:9990 file:/dev/null &
>>>> [12] 22499
>>>> [cperl@localhost ~]$ netstat -n --tcp | awk '$6 ~ /ESTABLISHED/ && $5
>>>> ~/:999[0-9]$/ {print $1, $4, $5}' | sort | column -t
>>>> tcp  192.168.0.11:60000  192.168.1.12:9990
>>>> tcp  192.168.0.11:60001  192.168.1.12:9990
>>>> tcp  192.168.0.11:60002  192.168.1.12:9990
>>>> tcp  192.168.0.11:60003  192.168.1.12:9990
>>>> tcp  192.168.0.11:60003  192.168.1.12:9991
>>>> tcp  192.168.0.11:60004  192.168.1.12:9990
>>>> tcp  192.168.0.11:60004  192.168.1.13:9990
>>>> tcp  192.168.0.11:60005  192.168.1.12:9990
>>>> tcp  192.168.0.11:60006  192.168.1.12:9990
>>>> tcp  192.168.0.11:60007  192.168.1.12:9990
>>>> tcp  192.168.0.11:60008  192.168.1.12:9990
>>>> tcp  192.168.0.11:60009  192.168.1.12:9990
>>>>
>>>> Is there any reason we couldn't modify `nfs_get_tcpclient' to not bind
>>>> in the case where its not using a reserved port?
>>>>
>>>> For some color, this is particularly annoying for me because I have
>>>> extensive automount maps and this failure leads to attempts to access
>>>> a given automounted path returning ENOENT.  Furthermore, automount
>>>> caches this failure and continues to return ENOENT for the duration of
>>>> whatever its negative cache timeout is.
>>>>
>>>> For UDP, I don't think "bind before connect" matters as much.  I
>>>> believe the difference is just in the error you'll get from either
>>>> bind or connect (if all ephemeral ports are used).  If you attempt to
>>>> bind when all local ports are in use you seem to get EADDRINUSE,
>>>> whereas when you connect when all local ports are in use you get
>>>> EAGAIN.
>>
>> There is only one place where mount.nfs uses connected UDP, which
>> is nfs_ca_sockname(). But UDP connected sockets are less of a
>> hazard because they lack a 120 second TIME_WAIT after they are
>> closed.
>>
>>>> It could be I'm missing something totally obvious for why this is.  If
>>>> so, please let me know!
>>
>> The reason is I didn’t realize you could call connect(2) without
>> calling bind(2) first on STREAM sockets.
>>
>>> (cc'ing Chuck since he wrote a lot of that code)
>>>
>>> I'm not sure either. If there was a reason for that, it's likely lost
>>> to antiquity. In some cases, we really are expected to use reserved
>>> ports and I think you do have to bind() in order to get one. In the
>>> non-reserved case though it's likely we could skip binding altogether.
>>>
>>> What would probably be best is to roll up a patch that changes it, and
>>> propose it on the list.
>>
>> I’d like to see a prototype, too.
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>

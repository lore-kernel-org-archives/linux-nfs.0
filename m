Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41323 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946944AbcBSQ3u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Feb 2016 11:29:50 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1 Session Trunking"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160219150135.GD17042@fieldses.org>
Date: Fri, 19 Feb 2016 11:29:40 -0500
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D09C120D-FA37-4F41-803F-42CF4CF939F2@oracle.com>
References: <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com> <20160217205929.GF10401@fieldses.org> <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com> <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com> <CAHQdGtRO8e7LF_2E9hcSV90CsbbfkboX9VOUSiuQWRBs_EBGLA@mail.gmail.com> <20160218141447.GB4256@fieldses.org> <CAHQdGtRt-iuY-R3xQQyiXni=HD8DKzYX7pkaN=8xCuAWBeyOiw@mail.gmail.com> <839836DE-11FD-4310-A76E-630548C0777B@netapp.com> <20160218203915.GA7771@fieldses.org> <336DFCFA-5655-4CB1-82F2-9E3B17030094@oracle.com> <20160219150135.GD17042@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 19, 2016, at 10:01 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Thu, Feb 18, 2016 at 04:29:46PM -0500, Chuck Lever wrote:
>> True; there's a reason I never got to implementing
>> fs_locations_info on the Linux server for FedFS. There
>> are sticky problems around the mountd upcall that is
>> used to communicate this information to the kernel,
>> for example.
>> 
>> However, I don't agree that this is a good reason to
>> go with multiple hostnames on the mount command line.
>> I like Andy's plan to keep this CLI change out of the
>> long term upstream code, but continue to use it for
>> testing.
> 
> Even if we get an fs_locations_info-based solution to the point where
> it's the best default, don't you think we'll still want some kind of
> manual override on the client?

Perhaps! But that doesn't mean multiple hostnames in
particular is the right CLI.

Suppose a "notrunk" mount option was added. The client
would ignore the server's fs_locations_info and use
only the hostname provided on the command line.

Another idea is to provide a blacklist as a mount
option. "notrunk=IPv4,IPv4,[IPv6],[IPv6]"


> The decision here has to do with the path between client and server,
> and the server may not always be in the best position to make that
> decision.

The server is not making any decision about the path.
It simply provides a list of its i/f's.

The client may choose to use one or more of the IP
addresses on the server's list. The client is not
required to use all the server's IP addresses, and
it does have the ability to determine that some
addresses are not reachable (eg IPv6 addresses,
private networks, and so on), though that may take
a timeout or two.

But back to the client CLI:

With multiple hostnames, client admins can specify
arbitrary hostnames on the command line; hostnames
for instance that correspond to some other server.

And, network conditions can change at anytime, making
the original set of trunks lop-sided, or some trunks
may become unreachable. What if the server reboots
with new i/f's or with one or more removed? The
client would likely have to remount in these cases
to adapt to network configuration changes.

Note that multiple hostnames could be nailed into
/etc/fstab on potentially hundreds of clients. When
server or network configuration changes, there would
have to be a manual change on all these clients.


--
Chuck Lever





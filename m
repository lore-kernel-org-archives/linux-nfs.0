Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:40920 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838Ab0A0SXk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2010 13:23:40 -0500
Message-ID: <4B608492.2020702@oracle.com>
Date: Wed, 27 Jan 2010 13:23:14 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Whoop Whouzer <tiredandnumb@gmail.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Muntz, Daniel" <Dan.Muntz@netapp.com>,
        Peter Chacko <peterchacko35@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs client performance while server is down
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com> <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com> <d7f0b3a81001230827y52727993nf60210ae610643b7@mail.gmail.com> <7A24DF798E223B4C9864E8F92E8C93EC0527810C@SACMVEXC1-PRD.hq.netapp.com> <d7f0b3a81001241609v35e54740yea3fa1a251b4f953@mail.gmail.com> <0BA6F612-CE3A-47E9-B436-57E48506D769@oracle.com> <d7f0b3a81001251102p5e631706jfd9f147a00487061@mail.gmail.com> <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com> <20100126232148.GA806@fieldses.org>
In-Reply-To: <20100126232148.GA806@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/26/2010 06:21 PM, J. Bruce Fields wrote:
> On Mon, Jan 25, 2010 at 02:08:47PM -0500, Chuck Lever wrote:
>> On Jan 25, 2010, at 2:02 PM, Whoop Whouzer wrote:
>>> Ok, I did that, after shutting down the server and enabling debug
>>> trace I tried to open the home folder of the current account (totally
>>> unrelated to the nfsshare), it wouldn't open at all, I got no nautilus
>>> at all. During the time my cursor was in busy mode I got the following
>>> messages in kern.log (for ubuntu 10.04 client):
>>> Jan 25 19:30:13 whoop-desktop kernel: [  160.719262] NFS call  fsstat
>>> Jan 25 19:30:37 whoop-desktop kernel: [  184.458611] NFS:
>>> permission(0:16/74386), mask=0x10, res=0
>>> Jan 25 19:30:37 whoop-desktop kernel: [  184.458647] NFS call  access
>>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721086] nfs: server
>>> 192.168.1.130 not responding, timed out
>>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721113] NFS reply statfs:
>>> -5
>>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721116] nfs_statfs:
>>> statfs error = 5
> ...
>> This verifies that your client is attempting to access the NFS server,
>> but doesn't tell us which file it's attempting to access.  Essentially
>> the EIO means "failed to connect".
>
> I wonder if nautilus (or some library it uses) likes to regularly
> "statfs" all the filesystems it knows about?

The NFS client seems to like to send these periodically, but I've never 
looked into why.  It's probably triggered by some cache timeout, and 
gathers recent server file system information.

The ACCESS command is for a particular file, however.  That's probably 
where we will get the most interesting and specific information.  A 
network trace would capture the FH in the ACCESS request.  When the 
server is up, you could match that FH to other requests where the actual 
pathname of the file is known.

Simply run wireshark on your client, and it should automatically sniff 
the FH information.  Wireshark would need to be running while the server 
is up and continue running after the server is taken down.

-- 
chuck[dot]lever[at]oracle[dot]com

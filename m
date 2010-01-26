Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34791 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab0AZXUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 18:20:18 -0500
Date: Tue, 26 Jan 2010 18:21:48 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Whoop Whouzer <tiredandnumb@gmail.com>,
        "Muntz, Daniel" <Dan.Muntz@netapp.com>,
        Peter Chacko <peterchacko35@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs client performance while server is down
Message-ID: <20100126232148.GA806@fieldses.org>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com> <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com> <d7f0b3a81001230827y52727993nf60210ae610643b7@mail.gmail.com> <7A24DF798E223B4C9864E8F92E8C93EC0527810C@SACMVEXC1-PRD.hq.netapp.com> <d7f0b3a81001241609v35e54740yea3fa1a251b4f953@mail.gmail.com> <0BA6F612-CE3A-47E9-B436-57E48506D769@oracle.com> <d7f0b3a81001251102p5e631706jfd9f147a00487061@mail.gmail.com> <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 25, 2010 at 02:08:47PM -0500, Chuck Lever wrote:
> On Jan 25, 2010, at 2:02 PM, Whoop Whouzer wrote:
>> Ok, I did that, after shutting down the server and enabling debug
>> trace I tried to open the home folder of the current account (totally
>> unrelated to the nfsshare), it wouldn't open at all, I got no nautilus
>> at all. During the time my cursor was in busy mode I got the following
>> messages in kern.log (for ubuntu 10.04 client):
>> Jan 25 19:30:13 whoop-desktop kernel: [  160.719262] NFS call  fsstat
>> Jan 25 19:30:37 whoop-desktop kernel: [  184.458611] NFS:
>> permission(0:16/74386), mask=0x10, res=0
>> Jan 25 19:30:37 whoop-desktop kernel: [  184.458647] NFS call  access
>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721086] nfs: server
>> 192.168.1.130 not responding, timed out
>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721113] NFS reply statfs: 
>> -5
>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721116] nfs_statfs:
>> statfs error = 5
...
> This verifies that your client is attempting to access the NFS server,  
> but doesn't tell us which file it's attempting to access.  Essentially  
> the EIO means "failed to connect".

I wonder if nautilus (or some library it uses) likes to regularly
"statfs" all the filesystems it knows about?

--b.

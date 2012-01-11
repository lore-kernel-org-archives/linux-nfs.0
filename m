Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40597 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757528Ab2AKN3R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2012 08:29:17 -0500
Message-ID: <4F0D8E95.60706@panasas.com>
Date: Wed, 11 Jan 2012 15:28:53 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        <lsf-pc@lists.linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] linux-pnfs server implementations
References: <4EF6A6CA.1020606@tonian.com> <4F0AE25C.5020706@panasas.com> <20120109192517.GB16973@fieldses.org> <CAEMWVhvaNOENPC2jRMB7zuP4ScsNmp5BMfXYmnFL71_N-4D0Rw@mail.gmail.com>
In-Reply-To: <CAEMWVhvaNOENPC2jRMB7zuP4ScsNmp5BMfXYmnFL71_N-4D0Rw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/11/2012 09:44 AM, Benny Halevy wrote:
>>
>> Understood that it may depend on where things stand in April, but: what
>> specifically do you think will be likely to require the attention of a
>> wider group of linux filesystem developers (ass opposed to just nfs
>> developers)?
> 
> I have nothing specific at this time. My thinking was to present the
> what's and why's
> of the prerequisites in high level and maybe provide an example.
> 

At the time there where some reservations from people about some of the
added hooks and vectors. If there are still, we would like to hear them
and either address them or argue their validity.

I think this talk should be expanded with Jeff's suggestions. here:
> - RichACLs
> - Share/Deny mode support on open
> - mandatory locking that doesn't rely on weirdo file modes
> 
> It's always going to be hard for us to compete with dedicated
> appliances. Where Linux can shine though is in allowing for more
> innovative combinations.
> 
> Being able to do active/active NFS serving from clustered filesystems,
> for instance is something that we can eventually attain but that would
> be harder to do in an appliance. This sort of discussion might also
> dovetail with Benny's proposal about pNFS serving.

So the broader topic can be:
	"The things we want/need from the Kernel to make it exportable"

Thanks
Boaz

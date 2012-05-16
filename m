Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43010 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759941Ab2EPMPp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 08:15:45 -0400
Message-ID: <4FB39A64.1040909@panasas.com>
Date: Wed, 16 May 2012 15:15:32 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Idan Kedar <idank@tonian.com>
CC: Johannes Schild <JSchild@gmx.de>, <osd-dev@open-osd.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: Questions about Exofs
References: <20120515090332.182970@gmx.net> <4FB22658.9010909@panasas.com> <20120515121931.192500@gmx.net> <CABpMAy+bV7-UZU0gGOFWk+ZfHLGi+D=ntNLjRHFYZzTtwXG_RA@mail.gmail.com> <4FB25D2F.1070403@panasas.com> <CABpMAyJ9F5c52ntMCL1+gwDCcbMYMEkxVEHW7bfpjm6H5boSCg@mail.gmail.com> <4FB270E9.5000904@panasas.com> <CABpMAy+OWcp7VAOGK4nYWfcY4iZ9a1WQHPUbh5pxotYL9yy+KA@mail.gmail.com>
In-Reply-To: <CABpMAy+OWcp7VAOGK4nYWfcY4iZ9a1WQHPUbh5pxotYL9yy+KA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 07:21 PM, Idan Kedar wrote:

>>> By the way, several weeks I have tried setting up a RAID 5 environment
>>> >> with 8 OSDs, 1 mirror and RAID nesting. I then tried cloning and
>>> >> compiling the kernel tree over this pNFS-OSD-RAID. The result was that
>>> >> otgtd died, and I don't know why. It didn't dump core anywhere I could
>>> >> find and the only "log" it has - stdout - didn't give any useful info.
>>> >> I was going to inquire about this in a couple of weeks when I need to
>>> >> get this environment working, but since this issue came up, maybe we
>>> >> can somehow resolve it sooner.
>> >
>> >
>> > 8 OSDs with a mirror ? what was the mkfs.exofs command line you used?
> Something along the lines of
> # LD_LIBRARY_PATH=lib ./usr/mkfs.exofs --pid=0x10000 --format
> --mirrors=1 --group_width=2 --group_depth=2 --dev=/dev/osd0
> --osdname=$(uuid) --dev=/dev/osd1 --osdname=$(uuid) --dev=/dev/osd2
> --osdname=$(uuid) ...
> 
> I don't remember exactly at the moment, but I will bump this thread
> when I'll start using RAID again.
>> >


BTW I don't see a --raid=5 above but a raid5 of --group_width=2 is just
a mirror. The minimum for --raid=5 is 3. (I'm not sure if
the system checks and optimizes for this)

So the above should probably be:

# LD_LIBRARY_PATH=lib ./usr/mkfs.exofs --pid=0x10000 	\
  --mirrors=2 --group_width=2 --group_depth=1000 	\
  --dev=/dev/osd0 --format --osdname=$(uuid) 		\
  --dev=/dev/osd1 --format --osdname=$(uuid)		\
  --dev=/dev/osd2 --format --osdname=$(uuid)		\
  ...

group_depth is how many times to repeat this group until
advancing to the next group. 

The group_count is:
	group_count = int( (total_devices / mirrors+1) / group_width )

an interesting raid5 configuration with 8 devices mirrors and groups
can be:

# LD_LIBRARY_PATH=lib ./usr/mkfs.exofs --pid=0x10000 	\
  --mirrors=1 --raid=5 --group_width=3 --group_depth=1000 	\
  --dev=/dev/osd0 --format --osdname=$(uuid) 		\
  --dev=/dev/osd1 --format --osdname=$(uuid)		\
  --dev=/dev/osd2 --format --osdname=$(uuid)		\

Which means each file will have only a single group  - 3-out-of-4.
but the next file will use another set of 3 devices out of the 4.

And I think you need a --stripe_pages= right?

Cheers
Boaz

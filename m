From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions
Date: Mon, 03 Sep 2007 14:08:16 +0100
Message-ID: <46DC0740.1030507@zytor.com>
References: <46DBD982.3080102@googlemail.com>	<46DBDD8B.7040706@googlemail.com>	<b6a2187b0709030536w3e40f12bk4d25b6eb954d22b6@mail.gmail.com> <20070903055114.7f82ef46.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Chua <jeff.chua.linux@gmail.com>,
	michal.k.k.piotrowski@gmail.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, lists4me@web.de,
	adaplas@gmail.com, lenb@kernel.org, dth@dth.net,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond.Myklebust@netapp.com, andrew@digital-domain.net,
	peter.kovar@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070903055114.7f82ef46.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Andrew Morton wrote:
>> On Mon, 3 Sep 2007 20:36:32 +0800 "Jeff Chua" <jeff.chua.linux@gmail.com> wrote:
>> On 9/3/07, Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:
>>
>>> Subject         : console is messed up after resume from s2ram or switching to console from X
>>> References      : http://lkml.org/lkml/2007/8/4/6
>>> Last known good : ?
>>> Submitter       : Jeff Chua <jeff.chua.linux@gmail.com>
>>> Caused-By       : ?
>>> Handled-By      : H. Peter Anvin <hpa@zytor.com>
>>>                   Antonino A. Daplas <adaplas@gmail.com>
>>> Workaround      : "s2ram --force --acpi_sleep 1 --vbe_mode"
>>> Status          : problem is being debugged
>> Michal,
>>
>> Can you please close this case. I'm using the workaround and satisfied with it.
> 
> 2.6.21 was OK, and 2.6.23-rc2 needed a manual workaround?
> 
> That's a regression.

Yes, it is.  2.6.21 was OK, but only within a narrow and 
ill-characterized set of conditions (framebuffer not compiled into the 
kernel, in particular.)  It appears to me that the interaction between 
STR and video on this system is extremely fragile, to the point that any 
minor perturbations in the state can break it, and that that is the real 
underlying problem here.

	-hpa

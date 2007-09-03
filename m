From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions
Date: Mon, 03 Sep 2007 11:48:00 +0100
Message-ID: <46DBE660.9020309@zytor.com>
References: <46DBD982.3080102@googlemail.com> <46DBDD8B.7040706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Markus <lists4me@web.de>, Jeff Chua <jeff.chua.linux@gmail.com>,
	"Antonino A. Daplas" <adaplas@gmail.com>,
	Len Brown <lenb@kernel.org>, dth <dth@dth.net>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Clayton <andrew@digital-domain.net>,
	Peter Kovar <peter.kovar@gmail.com>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46DBDD8B.7040706@googlemail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Michal Piotrowski wrote:
> 
> Unclassified
> 
> Subject         : console is messed up after resume from s2ram or switching to console from X
> References      : http://lkml.org/lkml/2007/8/4/6
> Last known good : ?
> Submitter       : Jeff Chua <jeff.chua.linux@gmail.com>
> Caused-By       : ?
> Handled-By      : H. Peter Anvin <hpa@zytor.com>
>                   Antonino A. Daplas <adaplas@gmail.com>
> Workaround      : "s2ram --force --acpi_sleep 1 --vbe_mode"
> Status          : problem is being debugged
> 

I'm inclined to write this one off as general STR weirdness.  The 
problem is reproducible on 2.6.22 if CONFIG_FB is enabled (even if not 
*used*!), and there is a working workaround that is required on a lot of 
machines.

This is suboptimal, of course, but it seems to require a pretty deep 
investigation into the intricacies of this particular platform.

	-hpa
